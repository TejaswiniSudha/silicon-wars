import csv
import matplotlib.pyplot as plt

modes, gflops, speedups = [], [], []
with open("results.csv", "r") as f:
    for row in csv.DictReader(f):
        modes.append(row["mode"].replace("_", "\n"))
        gflops.append(float(row["gflops"]))
        speedups.append(float(row["speedup"]))

colors = ["#7f7f7f", "#ff7f0e", "#1f77b4", "#2ca02c"]
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11.5, 4.8))

# Left: Single-Core Throughput (GFLOP/s)
bars1 = ax1.bar(modes, gflops, color=colors, width=0.55)
for bar, g in zip(bars1, gflops):
    ax1.text(bar.get_x() + bar.get_width() / 2, g + 1.5, f"{g:.2f}",
             ha="center", va="bottom", fontsize=9, fontweight="bold")
ax1.set_title("Ryzen 9 8940HX: Single-Core SIMD Throughput")
ax1.set_ylabel("Throughput (GFLOP/s)")
ax1.set_ylim(0, 88)
ax1.grid(axis="y", linestyle=":", alpha=0.6)

# Right: Speedup vs Scalar
bars2 = ax2.bar(modes, speedups, color=colors, width=0.55)
for bar, s in zip(bars2, speedups):
    ax2.text(bar.get_x() + bar.get_width() / 2, s + 0.25, f"{s:.2f}x",
             ha="center", va="bottom", fontsize=9, fontweight="bold")
ax2.set_title("SIMD Speedup vs. Scalar Baseline")
ax2.set_ylabel("Speedup Multiplier (x)")
ax2.set_ylim(0, 14.5)
ax2.grid(axis="y", linestyle=":", alpha=0.6)

plt.tight_layout()
plt.savefig("simd_scaling.png", dpi=150)
print("Saved simd_scaling.png")
