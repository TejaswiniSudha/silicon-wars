#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

#define N_OPS (2 * 1024 * 1024)   // 2M useful floats read + 2M written (16 MB useful traffic)
#define MAX_STRIDE 32

__global__ void strided_copy(const float * __restrict__ in, float * __restrict__ out, int n_ops, int stride) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n_ops) {
        size_t pos = (size_t)idx * stride;
        out[pos] = in[pos] + 1.0f;
    }
}

int main(void) {
    size_t total_elems = (size_t)N_OPS * MAX_STRIDE;
    size_t total_bytes = total_elems * sizeof(float); // 256 MB per buffer

    float *d_in, *d_out;
    cudaMalloc(&d_in, total_bytes);
    cudaMalloc(&d_out, total_bytes);
    cudaMemset(d_in, 1, total_bytes);
    cudaMemset(d_out, 0, total_bytes);

    int strides[] = {1, 2, 4, 8, 16, 32};
    int num_tests = sizeof(strides) / sizeof(strides[0]);
    int threads = 256;
    int blocks = (N_OPS + threads - 1) / threads;
    const int REPS = 20;

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    double base_bw = 0.0;
    printf("stride,time_ms,bandwidth_gbs,efficiency_pct\n");

    for (int i = 0; i < num_tests; i++) {
        int s = strides[i];

        // Warm-up
        strided_copy<<<blocks, threads>>>(d_in, d_out, N_OPS, s);
        cudaDeviceSynchronize();

        cudaEventRecord(start);
        for (int r = 0; r < REPS; r++) {
            strided_copy<<<blocks, threads>>>(d_in, d_out, N_OPS, s);
        }
        cudaEventRecord(stop);
        cudaEventSynchronize(stop);

        float total_ms = 0.0f;
        cudaEventElapsedTime(&total_ms, start, stop);
        double avg_ms = total_ms / REPS;

        // Effective bandwidth = useful bytes moved (read + write) / time
        double useful_bytes = 2.0 * N_OPS * sizeof(float);
        double bw_gbs = useful_bytes / (avg_ms * 1e6);

        if (s == 1) base_bw = bw_gbs;
        double eff_pct = (bw_gbs / base_bw) * 100.0;

        printf("%d,%.4f,%.2f,%.1f\n", s, avg_ms, bw_gbs, eff_pct);
        fflush(stdout);
    }

    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    cudaFree(d_in);
    cudaFree(d_out);
    return 0;
}
