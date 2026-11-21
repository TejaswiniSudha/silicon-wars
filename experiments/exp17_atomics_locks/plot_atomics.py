import csv
import matplotlib.pyplot as plt

cpu_t, cpu_c, cpu_u = [], [], []
with open("results_cpu.csv", "r") as f:
    for row in csv.DictReader(f):
        cpu_t.append(row["threads"])
        cpu_c.append(float(row["contended_ms"]))
        cpu_u.append(float(row["uncontended_ms"]))

gpu_b, gpu_c, gpu_u = [], [], []
with open("results_gpu.csv", "r") as f:
    for row in csv.DictReader(f):
        gpu_b.append(row["blocks"])
        gpu_c.append(float(row["contended_ms"]))
        gpu_u.append(float(row["uncontended_ms"]))

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11.5, 4.8))

# Left: CPU Contended vs Uncontended Time (log scale)
x_cpu = range(len(cpu_t))
w = 0.36
ax1.bar([i - w/2 for i in x_cpu], cpu_c, width=w, color="#d62728", label="Contended (omp atomic)")
ax1.bar([i + w/2 for i in x_cpu], cpu_u, width=w, color="#2ca02c", label="Uncontended (reduction)")
ax1.set_yscale("log")
ax1.set_xticks(list(x_cpu))
ax1.set_xticklabels(cpu_t)
ax1.set_title("Ryzen 9 8940HX: Atomic Contention vs. Threads")
ax1.set_xlabel("OpenMP Threads")
ax1.set_ylabel("Time (ms, log scale) — Lower is Better")
ax1.legend()
ax1.grid(True, which="both", linestyle=":", alpha=0.5)

# Right: GPU Contended vs Uncontended Time
x_gpu = range(len(gpu_b))
ax2.bar([i - w/2 for i in x_gpu], gpu_c, width=w, color="#ff7f0e", label="Contended (global atomicAdd)")
ax2.bar([i + w/2 for i in x_gpu], gpu_u, width=w, color="#1f77b4", label="Uncontended (per-thread)")
ax2.set_xticks(list(x_gpu))
ax2.set_xticklabels(gpu_b)
ax2.set_title("RTX 5050: Global atomicAdd Scaling vs. Blocks")
ax2.set_xlabel("Thread Blocks (256 threads/block)")
ax2.set_ylabel("Execution Time (ms) — Lower is Better")
ax2.legend()
ax2.grid(True, axis="y", linestyle=":", alpha=0.6)

plt.tight_layout()
plt.savefig("atomics_locks.png", dpi=150)
print("Saved atomics_locks.png")
