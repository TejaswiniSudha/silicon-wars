import csv
import matplotlib.pyplot as plt

labels = []
gflops = []
times_ms = []
colors = []

# Load CPU results from Experiment 5
with open("../exp05_matmul_tiling/results.csv", "r") as f:
    for row in csv.DictReader(f):
        labels.append("CPU\n" + row["variant"])
        gflops.append(float(row["gflops"]))
        times_ms.append(float(row["time_ms"]))
        colors.append("#1f77b4")

# Load GPU results from Experiment 6
with open("results.csv", "r") as f:
    for row in csv.DictReader(f):
        labels.append("GPU\n" + row["variant"])
        gflops.append(float(row["gflops"]))
        times_ms.append(float(row["time_ms"]))
        colors.append("#2ca02c")

plt.figure(figsize=(10, 6))
bars = plt.bar(labels, gflops, color=colors, width=0.55)

for bar, g, t in zip(bars, gflops, times_ms):
    plt.text(
        bar.get_x() + bar.get_width() / 2,
        bar.get_height() + 20,
        f"{g:.1f} GFLOP/s\n({t:.2f} ms)",
        ha="center",
        va="bottom",
        fontsize=9,
        fontweight="bold",
    )

plt.title("1024x1024 Matrix Multiplication: Ryzen 9 8940HX (CPU) vs. RTX 5050 (GPU)")
plt.ylabel("Throughput (GFLOP/s)")
plt.ylim(0, max(gflops) * 1.18)
plt.grid(axis="y", linestyle=":", alpha=0.6)
plt.tight_layout()
plt.savefig("gpu_matmul_perf.png", dpi=150)
print("Saved gpu_matmul_perf.png")
