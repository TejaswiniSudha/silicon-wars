#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

#define N (32 * 1024 * 1024) // 32M floats = 128 MB per buffer
#define WORK_ITERS 4096      // ~26 ms compute vs ~20 ms PCIe round-trip

__global__ void compute_kernel(const float * __restrict__ in, float * __restrict__ out, int n) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        float x = in[idx];
        #pragma unroll 8
        for (int k = 0; k < WORK_ITERS; k++) {
            x = fmaf(x, 1.0001f, 0.0001f);
        }
        out[idx] = x;
    }
}

int main(void) {
    size_t bytes = (size_t)N * sizeof(float);

    float *h_in, *h_out;
    cudaMallocHost(&h_in, bytes);
    cudaMallocHost(&h_out, bytes);
    for (int i = 0; i < N; i++) h_in[i] = 1.0f;

    float *d_in, *d_out;
    cudaMalloc(&d_in, bytes);
    cudaMalloc(&d_out, bytes);

    int stream_counts[] = {1, 2, 4, 8, 16};
    int num_tests = sizeof(stream_counts) / sizeof(stream_counts[0]);
    const int REPS = 5;
    const int THREADS = 256;

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    double base_ms = 0.0;
    printf("streams,time_ms,speedup\n");

    for (int t = 0; t < num_tests; t++) {
        int n_streams = stream_counts[t];
        int chunk_elems = N / n_streams;
        size_t chunk_bytes = (size_t)chunk_elems * sizeof(float);
        int blocks = (chunk_elems + THREADS - 1) / THREADS;

        cudaStream_t *streams = (cudaStream_t *)malloc(n_streams * sizeof(cudaStream_t));
        for (int s = 0; s < n_streams; s++) {
            cudaStreamCreateWithFlags(&streams[s], cudaStreamNonBlocking);
        }

        // Warm-up (breadth-first)
        for (int s = 0; s < n_streams; s++)
            cudaMemcpyAsync(d_in + s * chunk_elems, h_in + s * chunk_elems, chunk_bytes, cudaMemcpyHostToDevice, streams[s]);
        for (int s = 0; s < n_streams; s++)
            compute_kernel<<<blocks, THREADS, 0, streams[s]>>>(d_in + s * chunk_elems, d_out + s * chunk_elems, chunk_elems);
        for (int s = 0; s < n_streams; s++)
            cudaMemcpyAsync(h_out + s * chunk_elems, d_out + s * chunk_elems, chunk_bytes, cudaMemcpyDeviceToHost, streams[s]);
        cudaDeviceSynchronize();

        cudaEventRecord(start);
        for (int r = 0; r < REPS; r++) {
            for (int s = 0; s < n_streams; s++)
                cudaMemcpyAsync(d_in + s * chunk_elems, h_in + s * chunk_elems, chunk_bytes, cudaMemcpyHostToDevice, streams[s]);
            for (int s = 0; s < n_streams; s++)
                compute_kernel<<<blocks, THREADS, 0, streams[s]>>>(d_in + s * chunk_elems, d_out + s * chunk_elems, chunk_elems);
            for (int s = 0; s < n_streams; s++)
                cudaMemcpyAsync(h_out + s * chunk_elems, d_out + s * chunk_elems, chunk_bytes, cudaMemcpyDeviceToHost, streams[s]);
            cudaDeviceSynchronize();
        }
        cudaEventRecord(stop);
        cudaEventSynchronize(stop);

        float total_ms = 0.0f;
        cudaEventElapsedTime(&total_ms, start, stop);
        double avg_ms = total_ms / REPS;

        if (n_streams == 1) base_ms = avg_ms;
        printf("%d,%.3f,%.2f\n", n_streams, avg_ms, base_ms / avg_ms);
        fflush(stdout);

        for (int s = 0; s < n_streams; s++) cudaStreamDestroy(streams[s]);
        free(streams);
    }

    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    cudaFree(d_in);
    cudaFree(d_out);
    cudaFreeHost(h_in);
    cudaFreeHost(h_out);
    return 0;
}
