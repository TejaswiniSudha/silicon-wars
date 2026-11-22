import csv
import matplotlib.pyplot as plt

platforms, e2e_ms, k_ms = [], [], []
with open("results.csv", "r") as f:
    for row in csv.DictReader(f):
        platforms.append(row["platform"])
        e2e_ms.append(float(row["e2e_ms"]))
        k_ms.append(float(row["kernel_only_ms"]))

x = range(len(platforms))
w = 0.36

fig, ax = plt.subplots(figsize=(9.5, 4.8))
b1 = ax.bar([i - w/2 for i in x], e2e_ms, width=w, color="#1f77b4", label="End-to-End (Alloc + H2D + Kernel + D2H + Free)")
b2 = ax.bar([i + w/2 for i in x], k_ms, width=w, color="#2ca02c", label="Kernel-Only Compute")

for bar, val in zip(b1, e2e_ms):
    ax.text(bar.get_x() + bar.get_width() / 2, val + 4, f"{val:.2f} ms",
            ha="center", va="bottom", fontsize=8.5, fontweight="bold")
for bar, val in zip(b2, k_ms):
    ax.text(bar.get_x() + bar.get_width() / 2, val + 4, f"{val:.2f} ms",
            ha="center", va="bottom", fontsize=8.5, fontweight="bold")

ax.set_xticks(list(x))
ax.set_xticklabels(platforms)
ax.set_title("End-to-End vs. Kernel-Only Execution Time (16M Floats, 64 FMA Steps)")
ax.set_ylabel("Time (ms) — Lower is Better")
ax.set_ylim(0, max(e2e_ms) * 1.18)
ax.legend()
ax.grid(axis="y", linestyle=":", alpha=0.6)

plt.tight_layout()
plt.savefig("end_to_end.png", dpi=150)
print("Saved end_to_end.png")
