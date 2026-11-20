#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

#define N 16000000
#define ITERS 64

// 1. Warp-coherent: all 32 threads in a warp take the same branch
__global__ void kernel_coherent(float *out, int n) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    if (tid >= n) return;

    float x = (float)(tid & 255) * 0.01f;
    if ((tid / 32) % 2 == 0) {
        for (int i = 0; i < ITERS; i++) x = x * 1.0001f + 0.5f;
    } else {
        for (int i = 0; i < ITERS; i++) x = x * 0.9999f - 0.5f;
    }
    out[tid] = x;
}

// 2. Warp-divergent: even/odd threads inside every warp split paths
__global__ void kernel_divergent(float *out, int n) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    if (tid >= n) return;

    float x = (float)(tid & 255) * 0.01f;
    if (tid % 2 == 0) {
        for (int i = 0; i < ITERS; i++) x = x * 1.0001f + 0.5f;
    } else {
        for (int i = 0; i < ITERS; i++) x = x * 0.9999f - 0.5f;
    }
    out[tid] = x;
}

int main(void) {
    size_t bytes = (size_t)N * sizeof(float);
    float *d_out;
    cudaMalloc(&d_out, bytes);

    int threads = 256;
    int blocks = (N + threads - 1) / threads;

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // Warm-up
    kernel_coherent<<<blocks, threads>>>(d_out, N);
    cudaDeviceSynchronize();

    // Benchmark Coherent
    cudaEventRecord(start);
    kernel_coherent<<<blocks, threads>>>(d_out, N);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float ms_coherent = 0.0f;
    cudaEventElapsedTime(&ms_coherent, start, stop);

    // Benchmark Divergent
    cudaEventRecord(start);
    kernel_divergent<<<blocks, threads>>>(d_out, N);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float ms_divergent = 0.0f;
    cudaEventElapsedTime(&ms_divergent, start, stop);

    printf("GPU,coherent_warp,%.3f,0\n", ms_coherent);
    printf("GPU,divergent_warp,%.3f,0\n", ms_divergent);

    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    cudaFree(d_out);
    return 0;
}
