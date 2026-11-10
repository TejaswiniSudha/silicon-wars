
#include <iostream>
#include <vector>
#include <cuda_runtime.h>
#include <chrono>

#define N 512

__global__ void matrixMultiply(float *A, float *B, float *C, int n) {
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

int main() {
    size_t bytes = N * N * sizeof(float);

    std::vector<float> A(N * N, 1.0f);
    std::vector<float> B(N * N, 2.0f);
    std::vector<float> C(N * N, 0.0f);

    // CPU matrix multiplication
    auto cpuStart = std::chrono::high_resolution_clock::now();

    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            float sum = 0.0f;

            for (int k = 0; k < N; k++) {
                sum += A[i * N + k] * B[k * N + j];
            }

            C[i * N + j] = sum;
        }
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

    cudaMemcpy(d_A, A.data(), bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, B.data(), bytes, cudaMemcpyHostToDevice);

    // GPU matrix multiplication
    dim3 threads(16, 16);
    dim3 blocks((N + 15) / 16, (N + 15) / 16);

    auto gpuStart = std::chrono::high_resolution_clock::now();

    matrixMultiply<<<blocks, threads>>>(d_A, d_B, d_C, N);

    cudaDeviceSynchronize();

    auto gpuEnd = std::chrono::high_resolution_clock::now();

    double gpuTime =
        std::chrono::duration<double, std::milli>(
            gpuEnd - gpuStart).count();

    cudaMemcpy(C.data(), d_C, bytes, cudaMemcpyDeviceToHost);

    std::cout << "Matrix Size: " << N << " x " << N << "\n";
    std::cout << "CPU Time: " << cpuTime << " ms\n";
    std::cout << "GPU Kernel Time: " << gpuTime << " ms\n";
    std::cout << "First Result: " << C[0] << "\n";

    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    return 0;
}
