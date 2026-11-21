#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

#define BLOCKS 4096
#define THREADS 256
#define ITERS 2048

__global__ void bank_conflict_kernel(unsigned int *out, int stride) {
    __shared__ volatile unsigned int smem[1024];

    int tid = threadIdx.x;
    for (int i = tid; i < 1024; i += blockDim.x) {
        smem[i] = i + 1;
    }
    __syncthreads();

    int lane = tid & 31;
    int idx = (lane * stride) & 1023;
    unsigned int acc = 0;

    #pragma unroll 8
    for (int k = 0; k < ITERS; k++) {
        acc += smem[idx];
    }

    if (acc == 0xFFFFFFFF) {
        out[blockIdx.x * blockDim.x + tid] = acc;
    }
}

int main(void) {
    unsigned int *d_out;
    cudaMalloc(&d_out, (size_t)BLOCKS * THREADS * sizeof(unsigned int));

    int strides[] = {1, 2, 4, 8, 16, 32, 33};
    int num_tests = sizeof(strides) / sizeof(strides[0]);
    const int REPS = 10;

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    double base_ms = 0.0;
    printf("stride,conflict_way,time_ms,slowdown\n");

    for (int i = 0; i < num_tests; i++) {
        int s = strides[i];
        int way = (s == 33) ? 1 : s;

        // Warm-up
        bank_conflict_kernel<<<BLOCKS, THREADS>>>(d_out, s);
        cudaDeviceSynchronize();

        cudaEventRecord(start);
        for (int r = 0; r < REPS; r++) {
            bank_conflict_kernel<<<BLOCKS, THREADS>>>(d_out, s);
        }
        cudaEventRecord(stop);
        cudaEventSynchronize(stop);

        float total_ms = 0.0f;
        cudaEventElapsedTime(&total_ms, start, stop);
        double avg_ms = total_ms / REPS;

        if (s == 1) base_ms = avg_ms;
        double slowdown = avg_ms / base_ms;

        printf("%d,%d,%.4f,%.2f\n", s, way, avg_ms, slowdown);
        fflush(stdout);
    }

    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    cudaFree(d_out);
    return 0;
}
