#include <iostream>
#include <cuda_runtime.h>

__global__ void helloGPU() {
    printf("Hello from the GPU!\n");
}

int main() {
    helloGPU<<<1, 1>>>();

    cudaDeviceSynchronize();

    std::cout << "Hello from the CPU!" << std::endl;

    return 0;
}
