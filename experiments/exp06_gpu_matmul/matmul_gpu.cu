#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

#define N 1024
#define TILE 16

// 1. Naive GPU MatMul (every thread reads directly from Global VRAM)
__global__ void matmul_naive(const float *A, const float *B, float *C, int n) {
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    if (row < n && col < n) {
        float sum = 0.0f;
        for (int k = 0; k < n; k++) {
            sum += A[row * n + k] * B[k * n + col];
        }
        C[row * n + col] = sum;
    }
}

// 2. Shared-Memory Tiled GPU MatMul (16x16 tiles loaded into fast on-chip SRAM)
__global__ void matmul_tiled(const float *A, const float *B, float *C, int n) {
    __shared__ float tileA[TILE][TILE];
    __shared__ float tileB[TILE][TILE];

    int row = blockIdx.y * TILE + threadIdx.y;
    int col = blockIdx.x * TILE + threadIdx.x;
    float sum = 0.0f;

    for (int t = 0; t < n / TILE; t++) {
        tileA[threadIdx.y][threadIdx.x] = A[row * n + (t * TILE + threadIdx.x)];
        tileB[threadIdx.y][threadIdx.x] = B[(t * TILE + threadIdx.y) * n + col];
        __syncthreads();

        for (int k = 0; k < TILE; k++) {
            sum += tileA[threadIdx.y][k] * tileB[k][threadIdx.x];
        }
        __syncthreads();
    }

    if (row < n && col < n) {
        C[row * n + col] = sum;
    }
}

int main(void) {
    size_t bytes = (size_t)N * N * sizeof(float);
    float *h_A = (float *)malloc(bytes);
    float *h_B = (float *)malloc(bytes);
    float *h_C_naive = (float *)malloc(bytes);
    float *h_C_tiled = (float *)malloc(bytes);

    srand(42);
    for (size_t i = 0; i < (size_t)N * N; i++) {
        h_A[i] = (float)(rand() % 100) / 100.0f;
        h_B[i] = (float)(rand() % 100) / 100.0f;
    }

    float *d_A, *d_B, *d_C;
    cudaMalloc(&d_A, bytes);
    cudaMalloc(&d_B, bytes);
    cudaMalloc(&d_C, bytes);

    cudaMemcpy(d_A, h_A, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, bytes, cudaMemcpyHostToDevice);

    dim3 threads(TILE, TILE);
    dim3 blocks(N / TILE, N / TILE);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    double flops = 2.0 * (double)N * (double)N * (double)N;
    printf("variant,matrix_size,tile_size,time_ms,gflops,max_diff\n");

    // Warm-up run
    matmul_naive<<<blocks, threads>>>(d_A, d_B, d_C, N);
    cudaDeviceSynchronize();

    // Benchmark Naive GPU
    cudaEventRecord(start);
    matmul_naive<<<blocks, threads>>>(d_A, d_B, d_C, N);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float ms_naive = 0.0f;
    cudaEventElapsedTime(&ms_naive, start, stop);
    cudaMemcpy(h_C_naive, d_C, bytes, cudaMemcpyDeviceToHost);
    printf("gpu_naive,%d,0,%.3f,%.2f,0.000000\n", N, ms_naive, (flops / (ms_naive * 1e-3)) / 1e9);

    // Benchmark Tiled GPU
    cudaEventRecord(start);
    matmul_tiled<<<blocks, threads>>>(d_A, d_B, d_C, N);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float ms_tiled = 0.0f;
    cudaEventElapsedTime(&ms_tiled, start, stop);
    cudaMemcpy(h_C_tiled, d_C, bytes, cudaMemcpyDeviceToHost);

    float max_diff = 0.0f;
    for (size_t i = 0; i < (size_t)N * N; i++) {
        float d = fabsf(h_C_naive[i] - h_C_tiled[i]);
        if (d > max_diff) max_diff = d;
    }
    printf("gpu_tiled_shared,%d,%d,%.3f,%.2f,%.6f\n", N, TILE, ms_tiled, (flops / (ms_tiled * 1e-3)) / 1e9, max_diff);

    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    cudaFree(d_A); cudaFree(d_B); cudaFree(d_C);
    free(h_A); free(h_B); free(h_C_naive); free(h_C_tiled);
    return 0;
}
