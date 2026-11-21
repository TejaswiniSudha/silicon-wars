#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <immintrin.h>

// 3.2 Billion FMAs = 6.4 Billion FLOPs per test
#define TOTAL_FMAS 3200000000LL

static double now_sec(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec + ts.tv_nsec * 1e-9;
}

__attribute__((noinline, optimize("no-tree-vectorize", "fp-contract=off")))
static float run_scalar(long long total_fmas) {
    float a0=1.0f, a1=1.1f, a2=1.2f, a3=1.3f, a4=1.4f, a5=1.5f, a6=1.6f, a7=1.7f;
    float m = 1.0000001f, c = 0.0000001f;
    long long iters = total_fmas / 8;
    for (long long i = 0; i < iters; i++) {
        a0 = a0 * m + c; a1 = a1 * m + c; a2 = a2 * m + c; a3 = a3 * m + c;
        a4 = a4 * m + c; a5 = a5 * m + c; a6 = a6 * m + c; a7 = a7 * m + c;
    }
    return a0 + a1 + a2 + a3 + a4 + a5 + a6 + a7;
}

__attribute__((noinline, optimize("fp-contract=off")))
static float run_sse(long long total_fmas) {
    __m128 a0=_mm_set1_ps(1.0f), a1=_mm_set1_ps(1.1f), a2=_mm_set1_ps(1.2f), a3=_mm_set1_ps(1.3f);
    __m128 a4=_mm_set1_ps(1.4f), a5=_mm_set1_ps(1.5f), a6=_mm_set1_ps(1.6f), a7=_mm_set1_ps(1.7f);
    __m128 m = _mm_set1_ps(1.0000001f), c = _mm_set1_ps(0.0000001f);
    long long iters = total_fmas / 32; // 8 accumulators * 4 floats
    for (long long i = 0; i < iters; i++) {
        a0 = _mm_add_ps(_mm_mul_ps(a0, m), c); a1 = _mm_add_ps(_mm_mul_ps(a1, m), c);
        a2 = _mm_add_ps(_mm_mul_ps(a2, m), c); a3 = _mm_add_ps(_mm_mul_ps(a3, m), c);
        a4 = _mm_add_ps(_mm_mul_ps(a4, m), c); a5 = _mm_add_ps(_mm_mul_ps(a5, m), c);
        a6 = _mm_add_ps(_mm_mul_ps(a6, m), c); a7 = _mm_add_ps(_mm_mul_ps(a7, m), c);
    }
    __m128 sum = _mm_add_ps(_mm_add_ps(_mm_add_ps(a0, a1), _mm_add_ps(a2, a3)),
                            _mm_add_ps(_mm_add_ps(a4, a5), _mm_add_ps(a6, a7)));
    float out[4];
    _mm_storeu_ps(out, sum);
    return out[0] + out[1] + out[2] + out[3];
}

__attribute__((noinline, optimize("fp-contract=off")))
static float run_avx2(long long total_fmas) {
    __m256 a0=_mm256_set1_ps(1.0f), a1=_mm256_set1_ps(1.1f), a2=_mm256_set1_ps(1.2f), a3=_mm256_set1_ps(1.3f);
    __m256 a4=_mm256_set1_ps(1.4f), a5=_mm256_set1_ps(1.5f), a6=_mm256_set1_ps(1.6f), a7=_mm256_set1_ps(1.7f);
    __m256 m = _mm256_set1_ps(1.0000001f), c = _mm256_set1_ps(0.0000001f);
    long long iters = total_fmas / 64; // 8 accumulators * 8 floats
    for (long long i = 0; i < iters; i++) {
        a0 = _mm256_add_ps(_mm256_mul_ps(a0, m), c); a1 = _mm256_add_ps(_mm256_mul_ps(a1, m), c);
        a2 = _mm256_add_ps(_mm256_mul_ps(a2, m), c); a3 = _mm256_add_ps(_mm256_mul_ps(a3, m), c);
        a4 = _mm256_add_ps(_mm256_mul_ps(a4, m), c); a5 = _mm256_add_ps(_mm256_mul_ps(a5, m), c);
        a6 = _mm256_add_ps(_mm256_mul_ps(a6, m), c); a7 = _mm256_add_ps(_mm256_mul_ps(a7, m), c);
    }
    __m256 sum = _mm256_add_ps(_mm256_add_ps(_mm256_add_ps(a0, a1), _mm256_add_ps(a2, a3)),
                               _mm256_add_ps(_mm256_add_ps(a4, a5), _mm256_add_ps(a6, a7)));
    float out[8];
    _mm256_storeu_ps(out, sum);
    return out[0]+out[1]+out[2]+out[3]+out[4]+out[5]+out[6]+out[7];
}

__attribute__((noinline))
static float run_avx2_fma(long long total_fmas) {
    __m256 a0=_mm256_set1_ps(1.0f), a1=_mm256_set1_ps(1.1f), a2=_mm256_set1_ps(1.2f), a3=_mm256_set1_ps(1.3f);
    __m256 a4=_mm256_set1_ps(1.4f), a5=_mm256_set1_ps(1.5f), a6=_mm256_set1_ps(1.6f), a7=_mm256_set1_ps(1.7f);
    __m256 m = _mm256_set1_ps(1.0000001f), c = _mm256_set1_ps(0.0000001f);
    long long iters = total_fmas / 64; // 8 accumulators * 8 floats
    for (long long i = 0; i < iters; i++) {
        a0 = _mm256_fmadd_ps(a0, m, c); a1 = _mm256_fmadd_ps(a1, m, c);
        a2 = _mm256_fmadd_ps(a2, m, c); a3 = _mm256_fmadd_ps(a3, m, c);
        a4 = _mm256_fmadd_ps(a4, m, c); a5 = _mm256_fmadd_ps(a5, m, c);
        a6 = _mm256_fmadd_ps(a6, m, c); a7 = _mm256_fmadd_ps(a7, m, c);
    }
    __m256 sum = _mm256_add_ps(_mm256_add_ps(_mm256_add_ps(a0, a1), _mm256_add_ps(a2, a3)),
                               _mm256_add_ps(_mm256_add_ps(a4, a5), _mm256_add_ps(a6, a7)));
    float out[8];
    _mm256_storeu_ps(out, sum);
    return out[0]+out[1]+out[2]+out[3]+out[4]+out[5]+out[6]+out[7];
}

int main(void) {
    typedef float (*fn_t)(long long);
    const char *names[] = {"Scalar_32b", "SSE_128b", "AVX2_256b", "AVX2_FMA_256b"};
    int lanes[] = {1, 4, 8, 8};
    fn_t fns[] = {run_scalar, run_sse, run_avx2, run_avx2_fma};
    volatile float sink = 0.0f;
    double base_ms = 0.0;

    printf("mode,lanes,time_ms,gflops,speedup\n");
    for (int i = 0; i < 4; i++) {
        sink += fns[i](TOTAL_FMAS / 20); // warm-up
        double t0 = now_sec();
        sink += fns[i](TOTAL_FMAS);
        double ms = (now_sec() - t0) * 1000.0;
        double gflops = (2.0 * TOTAL_FMAS) / (ms * 1e6);
        if (i == 0) base_ms = ms;
        printf("%s,%d,%.3f,%.2f,%.2f\n", names[i], lanes[i], ms, gflops, base_ms / ms);
        fflush(stdout);
    }
    return sink == -1.0f;
}
