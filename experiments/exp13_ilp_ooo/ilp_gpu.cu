#include <stdio.h>
#include <cuda_runtime.h>

#define BLOCKS 64
#define THREADS 32
#define TOTAL_OPS 2000000

template <int K>
__global__ void ilp_kernel(float *out) {
    float a[K];
    #pragma unroll
    for (int j = 0; j < K; j++) a[j] = 1.0f + j * 0.1f;
    float m = 1.0000001f, c = 0.0000001f;
    int iters = TOTAL_OPS / K;

    for (int i = 0; i < iters; i++) {
        #pragma unroll
        for (int j = 0; j < K; j++) {
            a[j] = fmaf(a[j], m, c);
        }
    }

    float sum = 0.0f;
    #pragma unroll
    for (int j = 0; j < K; j++) sum += a[j];
    out[blockIdx.x * blockDim.x + threadIdx.x] = sum;
}

template <int K>
double bench(float *d_out) {
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    ilp_kernel<K><<<BLOCKS, THREADS>>>(d_out);
    cudaDeviceSynchronize();

    cudaEventRecord(start);
    ilp_kernel<K><<<BLOCKS, THREADS>>>(d_out);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float ms = 0.0f;
    cudaEventElapsedTime(&ms, start, stop);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    return (double)ms;
}

int main(void) {
    float *d_out;
    cudaMalloc(&d_out, BLOCKS * THREADS * sizeof(float));

    int chains[] = {1, 2, 4, 8, 16};
    double times[5];
    times[0] = bench<1>(d_out);
    times[1] = bench<2>(d_out);
    times[2] = bench<4>(d_out);
    times[3] = bench<8>(d_out);
    times[4] = bench<16>(d_out);

    double total_flops = 2.0 * TOTAL_OPS * BLOCKS * THREADS;
    printf("chains,gpu_ms,gpu_gflops,gpu_speedup\n");
    for (int i = 0; i < 5; i++) {
        double gflops = total_flops / (times[i] * 1e6);
        printf("%d,%.3f,%.2f,%.2f\n", chains[i], times[i], gflops, times[0] / times[i]);
    }

    cudaFree(d_out);
    return 0;
}
