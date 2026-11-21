#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <omp.h>

#define N 1024

static void matmul_ikj_omp(const float *A, const float *B, float *C, int n) {
    memset(C, 0, (size_t)n * n * sizeof(float));
    #pragma omp parallel for schedule(static)
    for (int i = 0; i < n; i++) {
        for (int k = 0; k < n; k++) {
            float a_ik = A[i * n + k];
            for (int j = 0; j < n; j++) {
                C[i * n + j] += a_ik * B[k * n + j];
            }
        }
    }
}

int main(void) {
    size_t bytes = (size_t)N * N * sizeof(float);
    float *A = (float *)aligned_alloc(64, bytes);
    float *B = (float *)aligned_alloc(64, bytes);
    float *C = (float *)aligned_alloc(64, bytes);

    for (int i = 0; i < N * N; i++) {
        A[i] = (float)(i % 100) * 0.01f;
        B[i] = (float)((i * 7) % 100) * 0.01f;
    }

    int thread_counts[] = {1, 2, 4, 8, 16, 32};
    int num_tests = sizeof(thread_counts) / sizeof(thread_counts[0]);
    const int REPS = 3;
    double base_ms = 0.0;

    printf("threads,time_ms,gflops,speedup\n");

    for (int t = 0; t < num_tests; t++) {
        int threads = thread_counts[t];
        omp_set_num_threads(threads);

        // Warm-up
        matmul_ikj_omp(A, B, C, N);

        double start = omp_get_wtime();
        for (int r = 0; r < REPS; r++) {
            matmul_ikj_omp(A, B, C, N);
        }
        double end = omp_get_wtime();

        double avg_sec = (end - start) / REPS;
        double avg_ms = avg_sec * 1000.0;
        double gflops = (2.0 * N * N * N) / (avg_sec * 1e9);

        if (threads == 1) base_ms = avg_ms;
        double speedup = base_ms / avg_ms;

        printf("%d,%.3f,%.2f,%.2f\n", threads, avg_ms, gflops, speedup);
        fflush(stdout);
    }

    free(A);
    free(B);
    free(C);
    return 0;
}
