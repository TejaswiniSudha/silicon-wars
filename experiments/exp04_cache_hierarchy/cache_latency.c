#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>

// Each node is 64 bytes = 1 cache line on Ryzen 9 8940HX
typedef struct Node {
    struct Node *next;
    char padding[56];
} Node;

static double now_ns(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (double)ts.tv_sec * 1e9 + (double)ts.tv_nsec;
}

int main(void) {
    // Sweep from 4 KB up to 512 MB
    size_t sizes_kb[] = {
        4, 8, 16, 32, 64, 128, 256, 512,
        1024, 2048, 4096, 8192, 16384, 32768,
        65536, 131072, 262144, 524288
    };
    int num_sizes = sizeof(sizes_kb) / sizeof(sizes_kb[0]);
    const long long HOPS = 5000000; // 5 million random pointer chases per size

    printf("size_kb,latency_ns\n");
    srand(42);

    for (int s = 0; s < num_sizes; s++) {
        size_t bytes = sizes_kb[s] * 1024ULL;
        size_t n = bytes / sizeof(Node);

        Node *nodes = (Node *)aligned_alloc(64, n * sizeof(Node));
        size_t *order = (size_t *)malloc(n * sizeof(size_t));
        if (!nodes || !order) {
            fprintf(stderr, "Allocation failed at %zu KB\n", sizes_kb[s]);
            break;
        }

        // Create a single random cycle visiting every cache line (Sattolo's algorithm)
        for (size_t i = 0; i < n; i++) order[i] = i;
        for (size_t i = n - 1; i > 0; i--) {
            size_t j = (size_t)rand() % i;
            size_t tmp = order[i];
            order[i] = order[j];
            order[j] = tmp;
        }
        for (size_t i = 0; i < n; i++) {
            nodes[order[i]].next = &nodes[order[(i + 1) % n]];
        }
        free(order);

        // Warm-up pass
        Node *p = &nodes[0];
        for (size_t i = 0; i < n && i < 100000; i++) {
            p = p->next;
        }

        // Timed random pointer chasing
        double t0 = now_ns();
        for (long long i = 0; i < HOPS; i++) {
            p = p->next;
        }
        double t1 = now_ns();

        // Prevent compiler from optimizing away the loop
        volatile uintptr_t sink = (uintptr_t)p;
        (void)sink;

        double latency_ns = (t1 - t0) / (double)HOPS;
        printf("%zu,%.2f\n", sizes_kb[s], latency_ns);
        fflush(stdout);

        free(nodes);
    }
    return 0;
}
