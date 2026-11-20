#include <stdio.h>
#include <cuda_runtime.h>

__global__ void saxpy_gpu(int n, float a, const float *x, float *y) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) {
        y[i] = a * x[i] + y[i];
    }
}

int main() {
    int n = 4;
    size_t bytes = n * sizeof(float);
    float h_x[4] = {1.0f, 2.0f, 3.0f, 4.0f};
    float h_y[4] = {10.0f, 20.0f, 30.0f, 40.0f};

    float *d_x, *d_y;
    cudaMalloc(&d_x, bytes);
    cudaMalloc(&d_y, bytes);

    cudaMemcpy(d_x, h_x, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_y, h_y, bytes, cudaMemcpyHostToDevice);

    saxpy_gpu<<<1, 256>>>(n, 2.0f, d_x, d_y);
    cudaDeviceSynchronize();

    cudaMemcpy(h_y, d_y, bytes, cudaMemcpyDeviceToHost);

    printf("y[0]=%.1f, y[3]=%.1f\n", h_y[0], h_y[3]);

    cudaFree(d_x);
    cudaFree(d_y);
    return 0;
}
