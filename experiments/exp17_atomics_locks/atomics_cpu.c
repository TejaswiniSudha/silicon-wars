#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <omp.h>

#define TOTAL_INCS 40000000LL

static double now_sec(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec + ts.tv_nsec * 1e-9;
}

static double bench_contended(int threads) {
    long long shared_counter = 0;
    long long per_thread = TOTAL_INCS / threads;

    // Warm-up
    #pragma omp parallel num_threads(threads)
    {
        for (long long i = 0; i < per_thread / 10; i++) {
            #pragma omp atomic
            shared_counter++;
        }
    }

    shared_counter = 0;
    double t0 = now_sec();
    #pragma omp parallel num_threads(threads)
    {
        for (long long i = 0; i < per_thread; i++) {
            #pragma omp atomic
            shared_counter++;
        }
    }
    double ms = (now_sec() - t0) * 1000.0;
    if (shared_counter < 0) printf("%lld\n", shared_counter);
    return ms;
}

static double bench_uncontended(int threads) {
    long long global_sum = 0;
    long long per_thread = TOTAL_INCS / threads;

    double t0 = now_sec();
    #pragma omp parallel num_threads(threads) reduction(+:global_sum)
    {
        long long local = 0;
        for (long long i = 0; i < per_thread; i++) {
            local++;
        }
        global_sum += local;
    }
    double ms = (now_sec() - t0) * 1000.0;
    if (global_sum < 0) printf("%lld\n", global_sum);
    return ms;
}

int main(void) {
    int thread_counts[] = {1, 2, 4, 8, 16, 32};
    int n = sizeof(thread_counts) / sizeof(thread_counts[0]);

    printf("threads,contended_ms,uncontended_ms,contention_slowdown\n");
    for (int i = 0; i < n; i++) {
        int t = thread_counts[i];
        double c_ms = bench_contended(t);
        double u_ms = bench_uncontended(t);
        printf("%d,%.3f,%.3f,%.2f\n", t, c_ms, u_ms, c_ms / u_ms);
        fflush(stdout);
    }
    return 0;
}
