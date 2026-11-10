
#include <iostream>
#include <vector>
#include <cuda_runtime.h>
#include <chrono>

#define N 10000000

__global__ void vectorAdd(float *A, float *B, float *C, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if (i < n) {
        C[i] = A[i] + B[i];
    }
}

int main() {
    size_t bytes = N * sizeof(float);

    std::vector<float> A(N, 1.5f);
    std::vector<float> B(N, 2.5f);
    std::vector<float> C(N);

    // CPU computation
    auto cpuStart = std::chrono::high_resolution_clock::now();

    for (int i = 0; i < N; i++) {
        C[i] = A[i] + B[i];
    }

    auto cpuEnd = std::chrono::high_resolution_clock::now();

    double cpuTime =
        std::chrono::duration<double, std::milli>(
            cpuEnd - cpuStart).count();

    // Allocate GPU memory
    float *d_A, *d_B, *d_C;

    cudaMalloc(&d_A, bytes);
    cudaMalloc(&d_B, bytes);
    cudaMalloc(&d_C, bytes);

    // Transfer data to GPU
    cudaMemcpy(d_A, A.data(), bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, B.data(), bytes, cudaMemcpyHostToDevice);

    // GPU computation
    int threads = 256;
    int blocks = (N + threads - 1) / threads;

    auto gpuStart = std::chrono::high_resolution_clock::now();

    vectorAdd<<<blocks, threads>>>(d_A, d_B, d_C, N);

    cudaDeviceSynchronize();

    auto gpuEnd = std::chrono::high_resolution_clock::now();

    double gpuTime =
        std::chrono::duration<double, std::milli>(
            gpuEnd - gpuStart).count();

    // Copy result back
    cudaMemcpy(C.data(), d_C, bytes, cudaMemcpyDeviceToHost);

    std::cout << "Vector Addition: " << N << " elements\n";
    std::cout << "CPU Time: " << cpuTime << " ms\n";
    std::cout << "GPU Kernel Time: " << gpuTime << " ms\n";
    std::cout << "First Result: " << C[0] << "\n";

    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    return 0;
}
