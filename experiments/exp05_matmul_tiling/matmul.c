#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>

#define N 1024
#define TILE 64

static double now_sec(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (double)ts.tv_sec + (double)ts.tv_nsec * 1e-9;
}

// 1. Naive i-j-k (column-wise access on B -> heavy cache misses)
void matmul_ijk(const float * restrict A, const float * restrict B, float * restrict C) {
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            float sum = 0.0f;
            for (int k = 0; k < N; k++) {
                sum += A[i * N + k] * B[k * N + j];
            }
            C[i * N + j] = sum;
        }
    }
}

// 2. Loop-reordered i-k-j (row-wise stride-1 access on B and C)
void matmul_ikj(const float * restrict A, const float * restrict B, float * restrict C) {
    memset(C, 0, (size_t)N * N * sizeof(float));
    for (int i = 0; i < N; i++) {
        for (int k = 0; k < N; k++) {
            float a = A[i * N + k];
            for (int j = 0; j < N; j++) {
                C[i * N + j] += a * B[k * N + j];
            }
        }
    }
}

// 3. Cache-tiled (blocked) i-k-j with 64x64 tiles
void matmul_tiled(const float * restrict A, const float * restrict B, float * restrict C) {
    memset(C, 0, (size_t)N * N * sizeof(float));
    for (int ii = 0; ii < N; ii += TILE) {
        for (int kk = 0; kk < N; kk += TILE) {
            for (int jj = 0; jj < N; jj += TILE) {
                for (int i = ii; i < ii + TILE; i++) {
                    for (int k = kk; k < kk + TILE; k++) {
                        float a = A[i * N + k];
                        for (int j = jj; j < jj + TILE; j++) {
                            C[i * N + j] += a * B[k * N + j];
                        }
                    }
                }
            }
        }
    }
}

int main(void) {
    size_t bytes = (size_t)N * N * sizeof(float);
    float *A = (float *)aligned_alloc(64, bytes);
    float *B = (float *)aligned_alloc(64, bytes);
    float *C_ijk = (float *)aligned_alloc(64, bytes);
    float *C_ikj = (float *)aligned_alloc(64, bytes);
    float *C_tiled = (float *)aligned_alloc(64, bytes);

    srand(42);
    for (size_t i = 0; i < (size_t)N * N; i++) {
        A[i] = (float)(rand() % 100) / 100.0f;
        B[i] = (float)(rand() % 100) / 100.0f;
    }

    double flops = 2.0 * (double)N * (double)N * (double)N;
    printf("variant,matrix_size,tile_size,time_ms,gflops,max_diff\n");

    // Run naive i-j-k
    double t0 = now_sec();
    matmul_ijk(A, B, C_ijk);
    double t1 = now_sec();
    double ms_ijk = (t1 - t0) * 1e3;
    printf("naive_ijk,%d,0,%.2f,%.2f,0.000000\n", N, ms_ijk, (flops / (t1 - t0)) / 1e9);
    fflush(stdout);

    // Run reordered i-k-j
    t0 = now_sec();
    matmul_ikj(A, B, C_ikj);
    t1 = now_sec();
    double ms_ikj = (t1 - t0) * 1e3;
    float diff_ikj = 0.0f;
    for (size_t i = 0; i < (size_t)N * N; i++) {
        float d = fabsf(C_ijk[i] - C_ikj[i]);
        if (d > diff_ikj) diff_ikj = d;
    }
    printf("reordered_ikj,%d,0,%.2f,%.2f,%.6f\n", N, ms_ikj, (flops / (t1 - t0)) / 1e9, diff_ikj);
    fflush(stdout);

    // Run cache-tiled
    t0 = now_sec();
    matmul_tiled(A, B, C_tiled);
    t1 = now_sec();
    double ms_tiled = (t1 - t0) * 1e3;
    float diff_tiled = 0.0f;
    for (size_t i = 0; i < (size_t)N * N; i++) {
        float d = fabsf(C_ijk[i] - C_tiled[i]);
        if (d > diff_tiled) diff_tiled = d;
    }
    printf("tiled_ikj,%d,%d,%.2f,%.2f,%.6f\n", N, TILE, ms_tiled, (flops / (t1 - t0)) / 1e9, diff_tiled);

    free(A); free(B); free(C_ijk); free(C_ikj); free(C_tiled);
    return 0;
}
