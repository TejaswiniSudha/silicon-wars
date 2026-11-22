import matplotlib.pyplot as plt

labels = [
    "Exp 15: Occupancy\n(64/128 vs 1024 blk)",
    "Exp 16: Streams\n(4 vs 1 stream)",
    "Exp 17: GPU Atomics\n(4096 blk contention)",
    "Exp 18: Roofline\n(AI=256 vs AI=0.25)",
    "Exp 19: E2E vs CPU\n(16M x 64 FMA)"
]
factors = [1.82, 1.38, 33.76, 92.09, 10.92]
colors = ["#1f77b4", "#2ca02c", "#d62728", "#9467bd", "#ff7f0e"]

fig, ax = plt.subplots(figsize=(10.5, 4.8))
bars = ax.barh(labels[::-1], factors[::-1], color=colors[::-1], height=0.55)
ax.set_xscale("log")

for bar, val in zip(bars, factors[::-1]):
    ax.text(val * 1.15, bar.get_y() + bar.get_height() / 2, f"{val:.2f}x",
            va="center", ha="left", fontsize=8.5, fontweight="bold")

ax.set_title("Silicon Wars (Exp 15–19): Measured Scaling & Bottleneck Ratios (Log Scale)")
ax.set_xlabel("Relative Ratio / Speedup / Contention Factor (x, log scale)")
ax.set_xlim(1, 300)
ax.grid(True, which="both", axis="x", linestyle=":", alpha=0.6)

plt.tight_layout()
plt.savefig("synthesis_matrix.png", dpi=150)
print("Saved synthesis_matrix.png")
