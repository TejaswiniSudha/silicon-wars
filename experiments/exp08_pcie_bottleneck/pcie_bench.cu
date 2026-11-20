#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <cuda_runtime.h>

static void run_bench(const char *mem_type, int pinned, size_t size_mb) {
    size_t bytes = size_mb * 1024ULL * 1024ULL;
    float *h_buf = NULL;
    float *d_buf = NULL;

    if (pinned) {
        cudaMallocHost(&h_buf, bytes);
    } else {
        h_buf = (float *)malloc(bytes);
    }
    cudaMalloc(&d_buf, bytes);
    memset(h_buf, 1, bytes);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    const int REPS = 5;

    // Warm-up
    cudaMemcpy(d_buf, h_buf, bytes, cudaMemcpyHostToDevice);
    cudaDeviceSynchronize();

    // Host-to-Device (H2D)
    cudaEventRecord(start);
    for (int r = 0; r < REPS; r++) {
        cudaMemcpy(d_buf, h_buf, bytes, cudaMemcpyHostToDevice);
    }
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float ms_h2d = 0.0f;
    cudaEventElapsedTime(&ms_h2d, start, stop);
    ms_h2d /= REPS;
    double gbps_h2d = ((double)bytes / (ms_h2d * 1e-3)) / 1e9;
    printf("%s,H2D,%zu,%.3f,%.2f\n", mem_type, size_mb, ms_h2d, gbps_h2d);

    // Device-to-Host (D2H)
    cudaEventRecord(start);
    for (int r = 0; r < REPS; r++) {
        cudaMemcpy(h_buf, d_buf, bytes, cudaMemcpyDeviceToHost);
    }
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float ms_d2h = 0.0f;
    cudaEventElapsedTime(&ms_d2h, start, stop);
    ms_d2h /= REPS;
    double gbps_d2h = ((double)bytes / (ms_d2h * 1e-3)) / 1e9;
    printf("%s,D2H,%zu,%.3f,%.2f\n", mem_type, size_mb, ms_d2h, gbps_d2h);
    fflush(stdout);

    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    cudaFree(d_buf);
    if (pinned) {
        cudaFreeHost(h_buf);
    } else {
        free(h_buf);
    }
}

int main(void) {
    size_t sizes_mb[] = {1, 4, 16, 64, 128, 256};
    int num_sizes = sizeof(sizes_mb) / sizeof(sizes_mb[0]);

    printf("memory_type,direction,size_mb,time_ms,bandwidth_gbps\n");
    for (int i = 0; i < num_sizes; i++) {
        run_bench("pageable", 0, sizes_mb[i]);
        run_bench("pinned", 1, sizes_mb[i]);
    }
    return 0;
}
