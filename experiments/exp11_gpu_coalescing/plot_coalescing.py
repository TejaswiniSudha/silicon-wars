import csv
import matplotlib.pyplot as plt

strides, bw, eff = [], [], []
with open("results.csv", "r") as f:
    for row in csv.DictReader(f):
        strides.append(int(row["stride"]))
        bw.append(float(row["bandwidth_gbs"]))
        eff.append(float(row["efficiency_pct"]))

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4.8))

# Left: Effective Bandwidth vs Stride
ax1.plot(strides, bw, "-o", color="#2ca02c", linewidth=2.2, markersize=7)
for s, b in zip(strides, bw):
    ax1.annotate(f"{b:.1f}", (s, b), textcoords="offset points",
                 xytext=(0, 8), ha="center", fontsize=8.5, fontweight="bold")
ax1.set_xscale("log", base=2)
ax1.set_xticks(strides)
ax1.set_xticklabels([str(s) for s in strides])
ax1.set_title("RTX 5050: Global Memory Coalescing Bandwidth")
ax1.set_xlabel("Access Stride (Elements / 4-Byte Floats)")
ax1.set_ylabel("Effective Bandwidth (GB/s)")
ax1.set_ylim(0, 840)
ax1.grid(True, linestyle=":", alpha=0.6)

# Right: Memory Efficiency (%)
bars = ax2.bar([str(s) for s in strides], eff, color="#1f77b4", width=0.55)
for bar, e in zip(bars, eff):
    ax2.text(bar.get_x() + bar.get_width() / 2, e + 2, f"{e:.1f}%",
             ha="center", va="bottom", fontsize=9, fontweight="bold")
ax2.set_title("Warp Memory Transaction Efficiency")
ax2.set_xlabel("Access Stride")
ax2.set_ylabel("Efficiency (% of Coalesced Peak)")
ax2.set_ylim(0, 115)
ax2.grid(axis="y", linestyle=":", alpha=0.6)

plt.tight_layout()
plt.savefig("coalescing_bw.png", dpi=150)
print("Saved coalescing_bw.png")
