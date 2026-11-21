import csv
import matplotlib.pyplot as plt

bs, occ, bw = [], [], []
with open("results.csv", "r") as f:
    for row in csv.DictReader(f):
        bs.append(row["block_size"])
        occ.append(float(row["occupancy_pct"]))
        bw.append(float(row["bandwidth_gbs"]))

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11.5, 4.8))

# Left: Effective VRAM Bandwidth (GB/s)
colors_bw = ["#2ca02c" if b >= 260 else "#1f77b4" if b >= 200 else "#d62728" for b in bw]
bars1 = ax1.bar(bs, bw, color=colors_bw, width=0.55)
for bar, b in zip(bars1, bw):
    ax1.text(bar.get_x() + bar.get_width() / 2, b + 5, f"{b:.1f}",
             ha="center", va="bottom", fontsize=8.5, fontweight="bold")
ax1.set_title("RTX 5050: VRAM Bandwidth vs. Thread Block Size")
ax1.set_xlabel("Threads per Block")
ax1.set_ylabel("Effective Bandwidth (GB/s)")
ax1.set_ylim(0, 300)
ax1.grid(axis="y", linestyle=":", alpha=0.6)

# Right: Theoretical SM Occupancy (%)
bars2 = ax2.bar(bs, occ, color="#ff7f0e", width=0.55)
for bar, o in zip(bars2, occ):
    ax2.text(bar.get_x() + bar.get_width() / 2, o + 2, f"{o:.1f}%",
             ha="center", va="bottom", fontsize=8.5, fontweight="bold")
ax2.set_title("Theoretical SM Occupancy (Max 48 Warps / 24 Blocks)")
ax2.set_xlabel("Threads per Block")
ax2.set_ylabel("Occupancy (%)")
ax2.set_ylim(0, 115)
ax2.grid(axis="y", linestyle=":", alpha=0.6)

plt.tight_layout()
plt.savefig("occupancy.png", dpi=150)
print("Saved occupancy.png")
