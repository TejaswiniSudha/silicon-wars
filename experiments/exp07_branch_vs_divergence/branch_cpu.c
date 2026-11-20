#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>

#define N 16000000
#define REPS 10

static double now_ms(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (double)ts.tv_sec * 1e3 + (double)ts.tv_nsec * 1e-6;
}

static int cmp_u8(const void *a, const void *b) {
    return (int)(*(const uint8_t *)a) - (int)(*(const uint8_t *)b);
}

// Keep this in a non-inlined function so GCC emits a real conditional branch
// (we'll compile with -fno-if-conversion to prevent cmov from hiding the branch)
__attribute__((noinline))
long long conditional_sum(const uint8_t *data, size_t n) {
    long long sum = 0;
    for (size_t i = 0; i < n; i++) {
        if (data[i] >= 128) {
            sum += data[i];
        }
    }
    return sum;
}

int main(void) {
    uint8_t *data = (uint8_t *)malloc(N * sizeof(uint8_t));
    if (!data) {
        fprintf(stderr, "Allocation failed\n");
        return 1;
    }

    srand(42);
    for (size_t i = 0; i < N; i++) {
        data[i] = (uint8_t)(rand() % 256);
    }

    // 1. Unsorted (unpredictable 50/50 branch)
    long long sum_unsorted = 0;
    double t0 = now_ms();
    for (int r = 0; r < REPS; r++) {
        sum_unsorted += conditional_sum(data, N);
    }
    double t1 = now_ms();
    double ms_unsorted = (t1 - t0) / REPS;

    // Sort the array
    qsort(data, N, sizeof(uint8_t), cmp_u8);

    // 2. Sorted (predictable branch: all false, then all true)
    long long sum_sorted = 0;
    t0 = now_ms();
    for (int r = 0; r < REPS; r++) {
        sum_sorted += conditional_sum(data, N);
    }
    t1 = now_ms();
    double ms_sorted = (t1 - t0) / REPS;

    printf("device,case,time_ms,checksum\n");
    printf("CPU,unsorted_branch,%.3f,%lld\n", ms_unsorted, sum_unsorted);
    printf("CPU,sorted_branch,%.3f,%lld\n", ms_sorted, sum_sorted);

    free(data);
    return 0;
}
