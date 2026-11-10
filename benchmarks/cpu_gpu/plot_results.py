import matplotlib.pyplot as plt
import numpy as np
import os

os.makedirs("../../docs", exist_ok=True)

experiments = ["Vector Addition", "Matrix Multiplication"]
cpu_times = [5.84, 129.78]
gpu_times = [4.94, 6.38]
speedups = [1.18, 20.34]

# Graph 1: CPU vs GPU execution time
x = np.arange(len(experiments))
width = 0.35

plt.figure(figsize=(10, 6))
plt.bar(x - width/2, cpu_times, width, label="CPU")
plt.bar(x + width/2, gpu_times, width, label="GPU")

plt.yscale("log")
plt.xlabel("Experiment")
plt.ylabel("Execution Time (ms) - Log Scale")
plt.title("CPU vs GPU Execution Time Comparison")
plt.xticks(x, experiments)
plt.legend()
plt.grid(axis="y", linestyle="--", alpha=0.5)
plt.tight_layout()
plt.savefig("../../docs/cpu_gpu_comparison.png", dpi=300)
plt.close()

# Graph 2: GPU speedup
plt.figure(figsize=(9, 5))
bars = plt.bar(experiments, speedups)

plt.ylabel("Speedup (x)")
plt.title("GPU Performance Speedup")
plt.grid(axis="y", linestyle="--", alpha=0.5)

for bar, value in zip(bars, speedups):
    plt.text(bar.get_x() + bar.get_width()/2,
             bar.get_height(),
             f"{value}x",
             ha="center", va="bottom")

plt.tight_layout()
plt.savefig("../../docs/gpu_speedup.png", dpi=300)
plt.close()

print("Both graphs generated successfully!")
