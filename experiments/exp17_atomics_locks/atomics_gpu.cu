#include <stdio.h>
#include <cuda_runtime.h>

#define TOTAL_INCS (64 * 1024 * 1024ULL) // 64M increments total
#define THREADS_PER_BLOCK 256

__global__ void kernel_contended(unsigned long long *counter, unsigned long long per_thread) {
    unsigned long long local = 0;
    for (unsigned long long i = 0; i < per_thread; i++) {
        local++;
    }
    // Force real global atomic updates per thread batch
    for (int k = 0; k < 64; k++) {
        atomicAdd(counter, local / 64 + (k == 0 ? local % 64 : 0));
    }
}

__global__ void kernel_uncontended(unsigned long long *out, unsigned long long per_thread) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    unsigned long long local = 0;
    for (unsigned long long i = 0; i < per_thread; i++) {
        local++;
    }
    out[tid] = local;
}

int main(void) {
    int block_counts[] = {16, 64, 256, 1024, 4096};
    int num_tests = sizeof(block_counts) / sizeof(block_counts[0]);

    unsigned long long *d_counter, *d_out;
    cudaMalloc(&d_counter, sizeof(unsigned long long));
    cudaMalloc(&d_out, 4096ULL * THREADS_PER_BLOCK * sizeof(unsigned long long));

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    printf("blocks,total_threads,contended_ms,uncontended_ms,contention_slowdown\n");

    for (int i = 0; i < num_tests; i++) {
        int blocks = block_counts[i];
        unsigned long long total_threads = (unsigned long long)blocks * THREADS_PER_BLOCK;
        unsigned long long per_thread = TOTAL_INCS / total_threads;
        if (per_thread < 1) per_thread = 1;

        cudaMemset(d_counter, 0, sizeof(unsigned long long));
        kernel_contended<<<blocks, THREADS_PER_BLOCK>>>(d_counter, per_thread);
        cudaDeviceSynchronize();

        cudaMemset(d_counter, 0, sizeof(unsigned long long));
        cudaEventRecord(start);
        kernel_contended<<<blocks, THREADS_PER_BLOCK>>>(d_counter, per_thread);
        cudaEventRecord(stop);
        cudaEventSynchronize(stop);
        float c_ms = 0.0f;
        cudaEventElapsedTime(&c_ms, start, stop);

        kernel_uncontended<<<blocks, THREADS_PER_BLOCK>>>(d_out, per_thread);
        cudaDeviceSynchronize();

        cudaEventRecord(start);
        kernel_uncontended<<<blocks, THREADS_PER_BLOCK>>>(d_out, per_thread);
        cudaEventRecord(stop);
        cudaEventSynchronize(stop);
        float u_ms = 0.0f;
        cudaEventElapsedTime(&u_ms, start, stop);

        printf("%d,%llu,%.4f,%.4f,%.2f\n", blocks, total_threads, (double)c_ms, (double)u_ms, (double)c_ms / u_ms);
        fflush(stdout);
    }

    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    cudaFree(d_counter);
    cudaFree(d_out);
    return 0;
}
