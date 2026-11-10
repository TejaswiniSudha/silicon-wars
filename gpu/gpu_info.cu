#include <iostream>
#include <cuda_runtime.h>

int main() {
    cudaDeviceProp prop;

    cudaGetDeviceProperties(&prop, 0);

    std::cout << "GPU Name: " << prop.name << std::endl;
    std::cout << "Number of SMs: " << prop.multiProcessorCount << std::endl;
    std::cout << "CUDA Cores per SM (architecture dependent)" << std::endl;
    std::cout << "Total Global Memory: "
              << prop.totalGlobalMem / (1024 * 1024) << " MB" << std::endl;

    return 0;
}
