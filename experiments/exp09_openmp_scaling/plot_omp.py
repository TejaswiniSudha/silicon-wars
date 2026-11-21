import csv
import matplotlib.pyplot as plt

threads, gflops, speedups = [], [], []
with open("results.csv", "r") as f:
    for row in csv.DictReader(f):
        threads.append(int(row["threads"]))
        gflops.append(float(row["gflops"]))
        speedups.append(float(row["speedup"]))

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4.8))

# Left: OpenMP Thread Scaling
ax1.plot(threads, gflops, "-o", color="#1f77b4", linewidth=2.2, markersize=7)
for t, g, s in zip(threads, gflops, speedups):
    ax1.annotate(f"{g:.1f}\n({s:.2f}x)", (t, g), textcoords="offset points",
                 xytext=(0, 8), ha="center", fontsize=8.5)
ax1.set_xscale("log", base=2)
ax1.set_xticks(threads)
ax1.set_xticklabels([str(t) for t in threads])
ax1.set_title("Ryzen 9 8940HX: OpenMP Scaling (1024x1024 MatMul)")
ax1.set_xlabel("OpenMP Threads")
ax1.set_ylabel("Throughput (GFLOP/s)")
ax1.set_ylim(0, 125)
ax1.grid(True, linestyle=":", alpha=0.6)

# Right: Best CPU vs. GPU (Exp 6)
labels = ["CPU 1-Thread\n(Ryzen 9)", "CPU 32-Threads\n(OpenMP)", "GPU Shared-Mem\n(RTX 5050, Exp 6)"]
values = [gflops[0], max(gflops), 1019.64]
colors = ["#ff7f0e", "#1f77b4", "#2ca02c"]
bars = ax2.bar(labels, values, color=colors, width=0.55)
for bar, val in zip(bars, values):
    ax2.text(bar.get_x() + bar.get_width() / 2, val + 20, f"{val:.1f} GFLOP/s",
             ha="center", va="bottom", fontsize=9, fontweight="bold")
ax2.set_title("Multi-Core CPU vs. GPU Peak Throughput")
ax2.set_ylabel("Throughput (GFLOP/s)")
ax2.set_ylim(0, 1180)
ax2.grid(axis="y", linestyle=":", alpha=0.6)

plt.tight_layout()
plt.savefig("openmp_scaling.png", dpi=150)
print("Saved openmp_scaling.png")
