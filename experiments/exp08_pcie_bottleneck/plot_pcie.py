import csv
import matplotlib.pyplot as plt

data = {
    ("pageable", "H2D"): ([], []),
    ("pageable", "D2H"): ([], []),
    ("pinned", "H2D"): ([], []),
    ("pinned", "D2H"): ([], []),
}

with open("results.csv", "r") as f:
    for row in csv.DictReader(f):
        key = (row["memory_type"], row["direction"])
        data[key][0].append(int(row["size_mb"]))
        data[key][1].append(float(row["bandwidth_gbps"]))

plt.figure(figsize=(9, 5.5))
styles = {
    ("pinned", "H2D"):   ("Pinned H2D (cudaMallocHost)", "#2ca02c", "-o"),
    ("pinned", "D2H"):   ("Pinned D2H (cudaMallocHost)", "#1f77b4", "--s"),
    ("pageable", "H2D"): ("Pageable H2D (malloc)", "#ff7f0e", "-^"),
    ("pageable", "D2H"): ("Pageable D2H (malloc)", "#d62728", "--v"),
}

for key, (label, color, fmt) in styles.items():
    sizes, bw = data[key]
    plt.plot(sizes, bw, fmt, label=label, color=color, linewidth=2, markersize=7)

plt.xscale("log", base=2)
plt.xticks([1, 4, 16, 64, 128, 256], ["1 MB", "4 MB", "16 MB", "64 MB", "128 MB", "256 MB"])
plt.title("PCIe Transfer Bandwidth: Pageable vs. Pinned Memory (RTX 5050)")
plt.xlabel("Transfer Size (MB, log2 scale)")
plt.ylabel("Bandwidth (GB/s)")
plt.ylim(0, 16.5)
plt.grid(True, linestyle=":", alpha=0.6)
plt.legend(loc="lower right")
plt.tight_layout()
plt.savefig("pcie_bandwidth.png", dpi=150)
print("Saved pcie_bandwidth.png")
