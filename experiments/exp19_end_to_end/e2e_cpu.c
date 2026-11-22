#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <omp.h>

#define N (16 * 1024 * 1024)
#define STEPS 64

static double now_ms(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec * 1000.0 + ts.tv_nsec * 1e-6;
}

int main(void) {
    float *in = (float *)aligned_alloc(64, (size_t)N * sizeof(float));
    float *out = (float *)aligned_alloc(64, (size_t)N * sizeof(float));
    for (int i = 0; i < N; i++) {
        in[i] = 1.0f + (i % 17) * 0.01f;
    }

    // Warm-up
    #pragma omp parallel for schedule(static)
    for (int i = 0; i < N; i++) {
        float x = in[i];
        for (int s = 0; s < 8; s++) x = x * 1.00001f + 0.0001f;
        out[i] = x;
    }

    double t0 = now_ms();
    #pragma omp parallel for schedule(static)
    for (int i = 0; i < N; i++) {
        float x = in[i];
        for (int s = 0; s < STEPS; s++) {
            x = x * 1.00001f + 0.0001f;
        }
        out[i] = x;
    }
    double total_ms = now_ms() - t0;

    volatile float sink = out[N - 1];
    (void)sink;

    printf("platform,e2e_ms,kernel_only_ms\n");
    printf("CPU_Ryzen9_8940HX,%.3f,%.3f\n", total_ms, total_ms);

    free(in);
    free(out);
    return 0;
}
