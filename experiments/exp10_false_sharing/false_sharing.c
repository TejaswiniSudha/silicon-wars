#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

#define ITERATIONS 100000000LL
#define MAX_THREADS 16

typedef struct {
    volatile long long count;
} PackedCounter;

typedef struct __attribute__((aligned(64))) {
    volatile long long count;
    char pad[56];
} PaddedCounter;

int main(void) {
    int thread_counts[] = {1, 2, 4, 8, 16};
    int num_tests = sizeof(thread_counts) / sizeof(thread_counts[0]);

    PackedCounter *packed = (PackedCounter *)aligned_alloc(64, MAX_THREADS * sizeof(PackedCounter));
    PaddedCounter *padded = (PaddedCounter *)aligned_alloc(64, MAX_THREADS * sizeof(PaddedCounter));

    printf("threads,packed_ms,padded_ms,slowdown\n");

    for (int t = 0; t < num_tests; t++) {
        int threads = thread_counts[t];
        omp_set_num_threads(threads);

        for (int i = 0; i < MAX_THREADS; i++) {
            packed[i].count = 0;
            padded[i].count = 0;
        }

        // 1. Packed (False Sharing)
        double start = omp_get_wtime();
        #pragma omp parallel
        {
            int tid = omp_get_thread_num();
            for (long long i = 0; i < ITERATIONS; i++) {
                packed[tid].count++;
            }
        }
        double packed_ms = (omp_get_wtime() - start) * 1000.0;

        // 2. Padded (Cache-Line Aligned)
        start = omp_get_wtime();
        #pragma omp parallel
        {
            int tid = omp_get_thread_num();
            for (long long i = 0; i < ITERATIONS; i++) {
                padded[tid].count++;
            }
        }
        double padded_ms = (omp_get_wtime() - start) * 1000.0;

        double slowdown = packed_ms / padded_ms;
        printf("%d,%.3f,%.3f,%.2f\n", threads, packed_ms, padded_ms, slowdown);
        fflush(stdout);
    }

    free(packed);
    free(padded);
    return 0;
}
