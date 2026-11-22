#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

#define N (16 * 1024 * 1024)
#define STEPS 64

__global__ void pipeline_kernel(const float * __restrict__ in, float * __restrict__ out, int n) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        float x = in[idx];
        #pragma unroll 8
        for (int s = 0; s < STEPS; s++) {
            x = fmaf(x, 1.00001f, 0.0001f);
        }
        out[idx] = x;
    }
}

int main(void) {
    size_t bytes = (size_t)N * sizeof(float);
    float *h_in = (float *)malloc(bytes);
    float *h_out = (float *)malloc(bytes);
    for (int i = 0; i < N; i++) {
        h_in[i] = 1.0f + (i % 17) * 0.01f;
    }

    // Warm-up
    float *d_w_in, *d_w_out;
    cudaMalloc(&d_w_in, bytes);
    cudaMalloc(&d_w_out, bytes);
    cudaMemcpy(d_w_in, h_in, bytes, cudaMemcpyHostToDevice);
    pipeline_kernel<<<(N + 255) / 256, 256>>>(d_w_in, d_w_out, N);
    cudaMemcpy(h_out, d_w_out, bytes, cudaMemcpyDeviceToHost);
    cudaFree(d_w_in);
    cudaFree(d_w_out);
    cudaDeviceSynchronize();

    cudaEvent_t e2e_start, e2e_stop, k_start, k_stop;
    cudaEventCreate(&e2e_start);
    cudaEventCreate(&e2e_stop);
    cudaEventCreate(&k_start);
    cudaEventCreate(&k_stop);

    float *d_in, *d_out;
    cudaEventRecord(e2e_start);
    cudaMalloc(&d_in, bytes);
    cudaMalloc(&d_out, bytes);
    cudaMemcpy(d_in, h_in, bytes, cudaMemcpyHostToDevice);

    cudaEventRecord(k_start);
    pipeline_kernel<<<(N + 255) / 256, 256>>>(d_in, d_out, N);
    cudaEventRecord(k_stop);
    cudaEventSynchronize(k_stop);

    cudaMemcpy(h_out, d_out, bytes, cudaMemcpyDeviceToHost);
    cudaFree(d_in);
    cudaFree(d_out);
    cudaEventRecord(e2e_stop);
    cudaEventSynchronize(e2e_stop);

    float e2e_ms = 0.0f, k_ms = 0.0f;
    cudaEventElapsedTime(&e2e_ms, e2e_start, e2e_stop);
    cudaEventElapsedTime(&k_ms, k_start, k_stop);

    volatile float sink = h_out[N - 1];
    (void)sink;

    printf("GPU_RTX5050,%.3f,%.3f\n", e2e_ms, k_ms);

    cudaEventDestroy(e2e_start);
    cudaEventDestroy(e2e_stop);
    cudaEventDestroy(k_start);
    cudaEventDestroy(k_stop);
    free(h_in);
    free(h_out);
    return 0;
}
