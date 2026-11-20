import csv
import matplotlib.pyplot as plt

cpu_cases, cpu_times = [], []
gpu_cases, gpu_times = [], []

with open("results.csv", "r") as f:
    for row in csv.DictReader(f):
        if row["device"] == "CPU":
            cpu_cases.append(row["case"].replace("_", "\n"))
            cpu_times.append(float(row["time_ms"]))
        elif row["device"] == "GPU":
            gpu_cases.append(row["case"].replace("_", "\n"))
            gpu_times.append(float(row["time_ms"]))

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(10, 5))

# CPU Panel
bars1 = ax1.bar(cpu_cases, cpu_times, color=["#d62728", "#2ca02c"], width=0.5)
for bar, t in zip(bars1, cpu_times):
    ax1.text(bar.get_x() + bar.get_width() / 2, t + 0.3, f"{t:.3f} ms", ha="center", fontweight="bold")
ax1.set_title("CPU: Branch Prediction (Ryzen 9 8940HX)\n7.58x Penalty on Unsorted Data")
ax1.set_ylabel("Time (ms) - Lower is Better")
ax1.set_ylim(0, max(cpu_times) * 1.2)
ax1.grid(axis="y", linestyle=":", alpha=0.6)

# GPU Panel
bars2 = ax2.bar(gpu_cases, gpu_times, color=["#2ca02c", "#d62728"], width=0.5)
for bar, t in zip(bars2, gpu_times):
    ax2.text(bar.get_x() + bar.get_width() / 2, t + 0.01, f"{t:.3f} ms", ha="center", fontweight="bold")
ax2.set_title("GPU: Warp Divergence (RTX 5050)\n1.61x Penalty on Divergent Warps")
ax2.set_ylabel("Time (ms) - Lower is Better")
ax2.set_ylim(0, max(gpu_times) * 1.25)
ax2.grid(axis="y", linestyle=":", alpha=0.6)

plt.tight_layout()
plt.savefig("branch_vs_divergence.png", dpi=150)
print("Saved branch_vs_divergence.png")
