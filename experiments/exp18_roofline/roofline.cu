#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

#define N (16 * 1024 * 1024) // 16M floats = 64 MB per array

// Streams 1 float in (4B) + 1 float out (4B) = 8 bytes per element.
// Each 'fma_steps' iteration does 1 FMA = 2 FLOPs per element.
__global__ void roofline_kernel(const float * __restrict__ in, float * __restrict__ out, int n, int fma_steps) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        float x = in[idx];
        float c = 0.00001f + (idx & 7) * 1e-6f;
        for (int s = 0; s < fma_steps; s++) {
            x = fmaf(x, 1.000001f, c);
        }
        out[idx] = x;
    }
}

int main(void) {
    size_t bytes = (size_t)N * sizeof(float);
    float *h_in = (float *)malloc(bytes);
    for (int i = 0; i < N; i++) h_in[i] = 1.0f + (i % 13) * 0.01f;

    float *d_in, *d_out;
    cudaMalloc(&d_in, bytes);
    cudaMalloc(&d_out, bytes);
    cudaMemcpy(d_in, h_in, bytes, cudaMemcpyHostToDevice);

    int steps_list[] = {1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024};
    int num_tests = sizeof(steps_list) / sizeof(steps_list[0]);
    const int THREADS = 256;
    const int BLOCKS = (N + THREADS - 1) / THREADS;

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    printf("fma_steps,ai_flops_per_byte,time_ms,gflops,achieved_bw_gbs\n");

    for (int i = 0; i < num_tests; i++) {
        int steps = steps_list[i];
        int reps = (steps <= 32) ? 20 : (steps <= 256 ? 8 : 4);

        // Warm-up
        roofline_kernel<<<BLOCKS, THREADS>>>(d_in, d_out, N, steps);
        cudaDeviceSynchronize();

        cudaEventRecord(start);
        for (int r = 0; r < reps; r++) {
            roofline_kernel<<<BLOCKS, THREADS>>>(d_in, d_out, N, steps);
        }
        cudaEventRecord(stop);
        cudaEventSynchronize(stop);

        float total_ms = 0.0f;
        cudaEventElapsedTime(&total_ms, start, stop);
        double avg_ms = total_ms / reps;

        // 8 bytes per element (1 read + 1 write of 4-byte float), 2 * steps FLOPs per element
        double total_bytes = 8.0 * N;
        double total_flops = 2.0 * steps * N;
        double ai = total_flops / total_bytes;
        double gflops = total_flops / (avg_ms * 1e6);
        double bw_gbs = total_bytes / (avg_ms * 1e6);

        printf("%d,%.2f,%.4f,%.2f,%.2f\n", steps, ai, avg_ms, gflops, bw_gbs);
        fflush(stdout);
    }

    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    cudaFree(d_in);
    cudaFree(d_out);
    free(h_in);
    return 0;
}
