#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define TOTAL_OPS 400000000LL

static double now_sec(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec + ts.tv_nsec * 1e-9;
}

static float run_ilp1(long long ops) {
    float a0 = 1.0f, m = 1.0000001f, c = 0.0000001f;
    for (long long i = 0; i < ops; i++) {
        a0 = a0 * m + c;
    }
    return a0;
}

static float run_ilp2(long long ops) {
    float a0 = 1.0f, a1 = 1.1f, m = 1.0000001f, c = 0.0000001f;
    for (long long i = 0; i < ops / 2; i++) {
        a0 = a0 * m + c;
        a1 = a1 * m + c;
    }
    return a0 + a1;
}

static float run_ilp4(long long ops) {
    float a0 = 1.0f, a1 = 1.1f, a2 = 1.2f, a3 = 1.3f, m = 1.0000001f, c = 0.0000001f;
    for (long long i = 0; i < ops / 4; i++) {
        a0 = a0 * m + c; a1 = a1 * m + c;
        a2 = a2 * m + c; a3 = a3 * m + c;
    }
    return a0 + a1 + a2 + a3;
}

static float run_ilp8(long long ops) {
    float a0=1.0f, a1=1.1f, a2=1.2f, a3=1.3f, a4=1.4f, a5=1.5f, a6=1.6f, a7=1.7f;
    float m = 1.0000001f, c = 0.0000001f;
    for (long long i = 0; i < ops / 8; i++) {
        a0 = a0 * m + c; a1 = a1 * m + c; a2 = a2 * m + c; a3 = a3 * m + c;
        a4 = a4 * m + c; a5 = a5 * m + c; a6 = a6 * m + c; a7 = a7 * m + c;
    }
    return a0 + a1 + a2 + a3 + a4 + a5 + a6 + a7;
}

static float run_ilp16(long long ops) {
    float a0=1.0f, a1=1.1f, a2=1.2f, a3=1.3f, a4=1.4f, a5=1.5f, a6=1.6f, a7=1.7f;
    float a8=1.8f, a9=1.9f, a10=2.0f, a11=2.1f, a12=2.2f, a13=2.3f, a14=2.4f, a15=2.5f;
    float m = 1.0000001f, c = 0.0000001f;
    for (long long i = 0; i < ops / 16; i++) {
        a0 = a0*m+c; a1 = a1*m+c; a2 = a2*m+c; a3 = a3*m+c;
        a4 = a4*m+c; a5 = a5*m+c; a6 = a6*m+c; a7 = a7*m+c;
        a8 = a8*m+c; a9 = a9*m+c; a10=a10*m+c; a11=a11*m+c;
        a12=a12*m+c; a13=a13*m+c; a14=a14*m+c; a15=a15*m+c;
    }
    return a0+a1+a2+a3+a4+a5+a6+a7+a8+a9+a10+a11+a12+a13+a14+a15;
}

int main(void) {
    typedef float (*fn_t)(long long);
    fn_t fns[] = {run_ilp1, run_ilp2, run_ilp4, run_ilp8, run_ilp16};
    int chains[] = {1, 2, 4, 8, 16};
    volatile float sink = 0.0f;
    double base_ms = 0.0;

    printf("chains,cpu_ms,cpu_gflops,cpu_speedup\n");
    for (int i = 0; i < 5; i++) {
        sink += fns[i](TOTAL_OPS / 10); // warm-up
        double t0 = now_sec();
        sink += fns[i](TOTAL_OPS);
        double ms = (now_sec() - t0) * 1000.0;
        double gflops = (2.0 * TOTAL_OPS) / (ms * 1e6);
        if (i == 0) base_ms = ms;
        printf("%d,%.3f,%.2f,%.2f\n", chains[i], ms, gflops, base_ms / ms);
        fflush(stdout);
    }
    return sink == -1.0f;
}
