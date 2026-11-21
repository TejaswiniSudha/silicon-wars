import csv
import matplotlib.pyplot as plt

chains, cpu_sp, cpu_gf = [], [], []
with open("results_cpu.csv", "r") as f:
    for row in csv.DictReader(f):
        chains.append(int(row["chains"]))
        cpu_sp.append(float(row["cpu_speedup"]))
        cpu_gf.append(float(row["cpu_gflops"]))

gpu_sp, gpu_gf = [], []
with open("results_gpu.csv", "r") as f:
    for row in csv.DictReader(f):
        gpu_sp.append(float(row["gpu_speedup"]))
        gpu_gf.append(float(row["gpu_gflops"]))

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11.5, 4.8))

# Left: Speedup Comparison (CPU vs GPU)
ax1.plot(chains, cpu_sp, "-o", color="#1f77b4", linewidth=2.2, markersize=7, label="CPU (Ryzen 9 8940HX)")
ax1.plot(chains, gpu_sp, "-s", color="#2ca02c", linewidth=2.2, markersize=7, label="GPU (RTX 5050)")
for c, cs, gs in zip(chains, cpu_sp, gpu_sp):
    ax1.annotate(f"{cs:.2f}x", (c, cs), textcoords="offset points", xytext=(0, 8), ha="center", fontsize=8.5, color="#1f77b4")
    ax1.annotate(f"{gs:.2f}x", (c, gs), textcoords="offset points", xytext=(0, -14), ha="center", fontsize=8.5, color="#2ca02c")
ax1.set_xscale("log", base=2)
ax1.set_xticks(chains)
ax1.set_xticklabels([str(c) for c in chains])
ax1.set_title("ILP Speedup vs. Independent Accumulator Chains")
ax1.set_xlabel("Independent FMA Chains")
ax1.set_ylabel("Speedup vs. 1 Chain (x)")
ax1.set_ylim(0, 9.5)
ax1.legend()
ax1.grid(True, linestyle=":", alpha=0.6)

# Right: GPU Absolute Throughput (GFLOP/s)
bars = ax2.bar([str(c) for c in chains], gpu_gf, color="#2ca02c", width=0.55)
for bar, g in zip(bars, gpu_gf):
    ax2.text(bar.get_x() + bar.get_width() / 2, g + 140, f"{g:.0f}",
             ha="center", va="bottom", fontsize=8.5, fontweight="bold")
ax2.set_title("RTX 5050: Throughput Scaling via ILP (Low Occupancy)")
ax2.set_xlabel("Independent FMA Chains")
ax2.set_ylabel("Throughput (GFLOP/s)")
ax2.set_ylim(0, 8200)
ax2.grid(axis="y", linestyle=":", alpha=0.6)

plt.tight_layout()
plt.savefig("ilp_ooo.png", dpi=150)
print("Saved ilp_ooo.png")
