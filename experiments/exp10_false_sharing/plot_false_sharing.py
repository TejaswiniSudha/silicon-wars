import csv
import matplotlib.pyplot as plt

threads, packed, padded, slowdowns = [], [], [], []
with open("results.csv", "r") as f:
    for row in csv.DictReader(f):
        threads.append(int(row["threads"]))
        packed.append(float(row["packed_ms"]))
        padded.append(float(row["padded_ms"]))
        slowdowns.append(float(row["slowdown"]))

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4.8))

# Left: Execution Time Comparison
ax1.plot(threads, packed, "-o", color="#d62728", linewidth=2.2, markersize=7, label="Packed (False Sharing)")
ax1.plot(threads, padded, "-s", color="#2ca02c", linewidth=2.2, markersize=7, label="64B Padded (No Sharing)")
ax1.set_xscale("log", base=2)
ax1.set_xticks(threads)
ax1.set_xticklabels([str(t) for t in threads])
ax1.set_title("False Sharing vs. 64-Byte Padding (100M Ops/Thread)")
ax1.set_xlabel("OpenMP Threads")
ax1.set_ylabel("Execution Time (ms) — Lower is Better")
ax1.legend()
ax1.grid(True, linestyle=":", alpha=0.6)

# Right: Slowdown Factor
bars = ax2.bar([str(t) for t in threads], slowdowns, color="#d62728", width=0.55)
for bar, s in zip(bars, slowdowns):
    ax2.text(bar.get_x() + bar.get_width() / 2, s + 0.3, f"{s:.2f}x",
             ha="center", va="bottom", fontsize=9, fontweight="bold")
ax2.set_title("Cache Coherence Slowdown Factor (Packed / Padded)")
ax2.set_xlabel("OpenMP Threads")
ax2.set_ylabel("Slowdown Multiplier (x)")
ax2.set_ylim(0, 14)
ax2.grid(axis="y", linestyle=":", alpha=0.6)

plt.tight_layout()
plt.savefig("false_sharing.png", dpi=150)
print("Saved false_sharing.png")
