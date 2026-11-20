import csv
import matplotlib.pyplot as plt

sizes_kb = []
latencies = []

with open("results.csv", "r") as f:
    reader = csv.DictReader(f)
    for row in reader:
        sizes_kb.append(float(row["size_kb"]))
        latencies.append(float(row["latency_ns"]))

plt.figure(figsize=(10, 6))
plt.plot(sizes_kb, latencies, marker="o", linewidth=2, color="#1f77b4")
plt.xscale("log", base=2)

# Mark actual Ryzen 9 8940HX cache boundaries
plt.axvline(32, color="green", linestyle="--", label="L1d (32 KB)")
plt.axvline(1024, color="orange", linestyle="--", label="L2 (1 MB)")
plt.axvline(32768, color="red", linestyle="--", label="L3 (32 MB)")

plt.title("AMD Ryzen 9 8940HX Cache Hierarchy Latency (Random Pointer Chasing)")
plt.xlabel("Working Set Size (KB, log2 scale)")
plt.ylabel("Latency per Access (ns)")
plt.grid(True, which="both", linestyle=":", alpha=0.6)
plt.legend()
plt.tight_layout()
plt.savefig("cache_latency.png", dpi=150)
print("Saved cache_latency.png")
