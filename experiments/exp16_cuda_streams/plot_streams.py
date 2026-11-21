import csv
import matplotlib.pyplot as plt

streams, times, speedups = [], [], []
with open("results.csv", "r") as f:
    for row in csv.DictReader(f):
        streams.append(row["streams"])
        times.append(float(row["time_ms"]))
        speedups.append(float(row["speedup"]))

colors = ["#d62728" if s == "1" else "#2ca02c" if s == "4" else "#1f77b4" for s in streams]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11.5, 4.8))

# Left: Total Execution Time (ms)
bars1 = ax1.bar(streams, times, color=colors, width=0.55)
for bar, t in zip(bars1, times):
    ax1.text(bar.get_x() + bar.get_width() / 2, t + 0.9, f"{t:.2f}",
             ha="center", va="bottom", fontsize=8.5, fontweight="bold")
ax1.set_title("RTX 5050: Total Time (H2D + Compute + D2H)")
ax1.set_xlabel("Number of CUDA Streams (Breadth-First Issue)")
ax1.set_ylabel("Execution Time (ms) — Lower is Better")
ax1.set_ylim(0, 55)
ax1.grid(axis="y", linestyle=":", alpha=0.6)

# Right: Overlap Speedup vs 1 Stream
bars2 = ax2.bar(streams, speedups, color=colors, width=0.55)
for bar, sp in zip(bars2, speedups):
    ax2.text(bar.get_x() + bar.get_width() / 2, sp + 0.03, f"{sp:.2f}x",
             ha="center", va="bottom", fontsize=8.5, fontweight="bold")
ax2.axhline(1.0, color="#7f7f7f", linestyle="--", linewidth=1)
ax2.set_title("PCIe Compute-Transfer Overlap Speedup")
ax2.set_xlabel("Number of CUDA Streams (Green = Peak Sweet Spot)")
ax2.set_ylabel("Speedup vs. 1 Stream (x)")
ax2.set_ylim(0, 1.65)
ax2.grid(axis="y", linestyle=":", alpha=0.6)

plt.tight_layout()
plt.savefig("streams_overlap.png", dpi=150)
print("Saved streams_overlap.png")
