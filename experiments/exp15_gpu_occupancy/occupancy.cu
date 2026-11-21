#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

#define N (32 * 1024 * 1024) // 32M floats (128 MB per buffer)

__global__ void saxpy_kernel(const float * __restrict__ a, const float * __restrict__ b, float * __restrict__ c, int n) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        c[idx] = a[idx] * 2.0f + b[idx];
    }
}

int main(void) {
    size_t bytes = (size_t)N * sizeof(float);
    float *d_a, *d_b, *d_c;
    cudaMalloc(&d_a, bytes);
    cudaMalloc(&d_b, bytes);
    cudaMalloc(&d_c, bytes);
    cudaMemset(d_a, 1, bytes);
    cudaMemset(d_b, 2, bytes);

    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, 0);
    int max_warps_per_sm = prop.maxThreadsPerMultiProcessor / 32;

    int block_sizes[] = {32, 64, 128, 256, 512, 1024};
    int num_tests = sizeof(block_sizes) / sizeof(block_sizes[0]);
    const int REPS = 20;

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    printf("block_size,active_blocks_sm,active_warps_sm,occupancy_pct,time_ms,bandwidth_gbs\n");

    for (int i = 0; i < num_tests; i++) {
        int bs = block_sizes[i];
        int grid = (N + bs - 1) / bs;

        int active_blocks = 0;
        cudaOccupancyMaxActiveBlocksPerMultiprocessor(&active_blocks, saxpy_kernel, bs, 0);
        int active_warps = active_blocks * (bs / 32);
        double occ_pct = (100.0 * active_warps) / max_warps_per_sm;

        // Warm-up
        saxpy_kernel<<<grid, bs>>>(d_a, d_b, d_c, N);
        cudaDeviceSynchronize();

        cudaEventRecord(start);
        for (int r = 0; r < REPS; r++) {
            saxpy_kernel<<<grid, bs>>>(d_a, d_b, d_c, N);
        }
        cudaEventRecord(stop);
        cudaEventSynchronize(stop);

        float total_ms = 0.0f;
        cudaEventElapsedTime(&total_ms, start, stop);
        double avg_ms = total_ms / REPS;

        // 2 reads (a, b) + 1 write (c) = 3 * N * 4 bytes
        double total_bytes = 3.0 * bytes;
        double bw_gbs = total_bytes / (avg_ms * 1e6);

        printf("%d,%d,%d,%.1f,%.4f,%.2f\n", bs, active_blocks, active_warps, occ_pct, avg_ms, bw_gbs);
        fflush(stdout);
    }

    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
    return 0;
}
