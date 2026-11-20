import csv
import matplotlib.pyplot as plt

variants = []
gflops = []
times_ms = []

with open("results.csv", "r") as f:
    reader = csv.DictReader(f)
    for row in reader:
        variants.append(row["variant"])
        gflops.append(float(row["gflops"]))
        times_ms.append(float(row["time_ms"]))

colors = ["#d62728", "#2ca02c", "#1f77b4"]
plt.figure(figsize=(8, 5))
bars = plt.bar(variants, gflops, color=colors, width=0.55)

for bar, g, t in zip(bars, gflops, times_ms):
    plt.text(
        bar.get_x() + bar.get_width() / 2,
        bar.get_height() + 0.5,
        f"{g:.2f} GFLOP/s\n({t:.1f} ms)",
        ha="center",
        va="bottom",
        fontsize=10,
        fontweight="bold",
    )

plt.title("1024x1024 Matrix Multiplication on AMD Ryzen 9 8940HX (-O3 -mavx2 -mfma)")
plt.ylabel("Throughput (GFLOP/s)")
plt.ylim(0, max(gflops) * 1.22)
plt.grid(axis="y", linestyle=":", alpha=0.6)
plt.tight_layout()
plt.savefig("matmul_perf.png", dpi=150)
print("Saved matmul_perf.png")
