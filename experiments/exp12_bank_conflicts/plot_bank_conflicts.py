import csv
import matplotlib.pyplot as plt

strides, times, slowdowns = [], [], []
with open("results.csv", "r") as f:
    for row in csv.DictReader(f):
        strides.append(row["stride"])
        times.append(float(row["time_ms"]))
        slowdowns.append(float(row["slowdown"]))

colors = ["#2ca02c" if s in ("1", "33") else "#d62728" for s in strides]
labels = [f"Stride {s}\n(+1 pad)" if s == "33" else f"Stride {s}" for s in strides]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11.5, 4.8))

# Left: Execution Time (ms)
bars1 = ax1.bar(labels, times, color=colors, width=0.58)
for bar, t in zip(bars1, times):
    ax1.text(bar.get_x() + bar.get_width() / 2, t + 0.8, f"{t:.2f}",
             ha="center", va="bottom", fontsize=8.5, fontweight="bold")
ax1.set_title("RTX 5050: Shared Memory Bank Conflict Latency")
ax1.set_xlabel("Access Stride (4-Byte Words)")
ax1.set_ylabel("Execution Time (ms) — Lower is Better")
ax1.set_ylim(0, 44)
ax1.grid(axis="y", linestyle=":", alpha=0.6)

# Right: Slowdown Multiplier
bars2 = ax2.bar(labels, slowdowns, color=colors, width=0.58)
for bar, s in zip(bars2, slowdowns):
    ax2.text(bar.get_x() + bar.get_width() / 2, s + 0.35, f"{s:.2f}x",
             ha="center", va="bottom", fontsize=8.5, fontweight="bold")
ax2.set_title("Serialization Slowdown vs. Conflict-Free Baseline")
ax2.set_xlabel("Access Stride (Green = Conflict-Free, Red = Conflicted)")
ax2.set_ylabel("Slowdown Multiplier (x)")
ax2.set_ylim(0, 18.5)
ax2.grid(axis="y", linestyle=":", alpha=0.6)

plt.tight_layout()
plt.savefig("bank_conflicts.png", dpi=150)
print("Saved bank_conflicts.png")
