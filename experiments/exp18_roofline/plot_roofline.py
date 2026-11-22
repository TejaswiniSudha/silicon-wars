import csv
import numpy as np
import matplotlib.pyplot as plt

ai, gflops, bw, steps = [], [], [], []
with open("results.csv", "r") as f:
    for row in csv.DictReader(f):
        steps.append(int(row["fma_steps"]))
        ai.append(float(row["ai_flops_per_byte"]))
        gflops.append(float(row["gflops"]))
        bw.append(float(row["achieved_bw_gbs"]))

ai = np.array(ai)
gflops = np.array(gflops)
bw = np.array(bw)

peak_bw = max(bw)              # ~258.19 GB/s observed streaming bandwidth
peak_compute = max(gflops)     # ~5944.31 GFLOP/s observed in loop

# Roofline envelope: min(peak_bw * AI, peak_compute)
ai_grid = np.logspace(np.log10(min(ai) * 0.7), np.log10(max(ai) * 1.4), 300)
mem_roof = peak_bw * ai_grid
compute_roof = np.full_like(ai_grid, peak_compute)
roof_line = np.minimum(mem_roof, compute_roof)
ridge_ai = peak_compute / peak_bw

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

# Left: Log-Log Roofline Model
ax1.loglog(ai_grid, roof_line, color="#1f77b4", linewidth=2.2, label=f"Roofline (BW={peak_bw:.1f} GB/s, Peak={peak_compute:.0f} GFLOP/s)")
ax1.loglog(ai_grid, mem_roof, color="#7f7f7f", linestyle="--", linewidth=1.1, label="Memory Bandwidth Roof")
ax1.axhline(peak_compute, color="#d62728", linestyle=":", linewidth=1.2, label="Observed Compute Roof")
ax1.axvline(ridge_ai, color="#ff7f0e", linestyle="-.", linewidth=1.1, label=f"Ridge Point (~{ridge_ai:.1f} FLOP/B)")
ax1.scatter(ai, gflops, color="#2ca02c", s=45, zorder=5, label="Measured Kernels")

ax1.set_title("RTX 5050 Roofline Model (FP32 FMA)")
ax1.set_xlabel("Arithmetic Intensity (FLOPs / Byte) — log scale")
ax1.set_ylabel("Throughput (GFLOP/s) — log scale")
ax1.legend(fontsize=7.8, loc="lower right")
ax1.grid(True, which="both", linestyle=":", alpha=0.5)

# Right: Achieved Bandwidth vs Arithmetic Intensity
ax2.semilogx(ai, bw, marker="o", color="#9467bd", linewidth=2)
ax2.set_title("Achieved Memory Bandwidth vs. Arithmetic Intensity")
ax2.set_xlabel("Arithmetic Intensity (FLOPs / Byte) — log scale")
ax2.set_ylabel("Effective Bandwidth (GB/s)")
ax2.set_ylim(0, max(bw) * 1.15)
ax2.grid(True, which="both", linestyle=":", alpha=0.5)

plt.tight_layout()
plt.savefig("roofline.png", dpi=150)
print(f"Saved roofline.png | Ridge AI ~ {ridge_ai:.2f} FLOPs/Byte")
