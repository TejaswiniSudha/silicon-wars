#include <stdio.h>

typedef struct {
    const char *scenario;
    const char *winner;
    const char *key_metric;
    const char *coa_reason;
} Row;

int main(void) {
    Row rows[] = {
        {"Low_Arithmetic_Intensity_Streaming", "GPU_BW_or_CPU_LowLat", "AI 0.25-2.0 FLOP/B", "Bounded by memory bandwidth before SM compute roof"},
        {"High_Arithmetic_Intensity_Compute", "GPU_RTX5050", "Peak ~5944 GFLOP/s at AI=256", "High FLOPs/byte amortizes memory traffic across many warps"},
        {"Shared_Counter_Atomic_Contention", "Avoid_Shared_Atomics", "33.76x GPU / 289.58x-36442x CPU", "Cache-line ping-pong & global atomic serialization bottleneck"},
        {"PCIe_Compute_Transfer_Pipeline", "GPU_MultiStream_4", "1.38x speedup vs 1 stream", "Breadth-first async streams overlap H2D/D2H with SM compute"},
        {"End_to_End_16M_64FMA_Workload", "GPU_RTX5050", "23.526 ms E2E (10.92x vs CPU)", "0.765 ms kernel (335.92x) outweighs ~22.76 ms alloc/PCIe"}
    };
    int n = sizeof(rows) / sizeof(rows[0]);

    printf("scenario,recommended_arch,key_metric,architectural_rule\n");
    for (int i = 0; i < n; i++) {
        printf("%s,%s,\"%s\",\"%s\"\n",
               rows[i].scenario, rows[i].winner, rows[i].key_metric, rows[i].coa_reason);
    }
    return 0;
}
