# Silicon Wars: 20-Experiment CPU vs. GPU Microarchitecture Suite

Empirical computer organization and architecture (COA) benchmark suite comparing the **AMD Ryzen 9 8940HX** (16 cores / 32 threads, AVX2, OpenMP) and **NVIDIA GeForce RTX 5050 Laptop GPU** (Blackwell, CUDA).

## Repository Layout

- `experiments/exp01_*` – `experiments/exp20_*`: Individual experiments containing source code (`C` / `CUDA` / plotting scripts), raw CSV results (`results*.csv`), visualizations (`.png`), and experiment-specific `README.md` notes.
- `run_demo.sh`: Automated demonstration runner (if present).

## Highlighted Takeaways (Experiments 15–20)

- **Exp 15 (GPU Occupancy):** Tuning block/grid launch configuration avoids under-utilization and excessive scheduling overhead.
- **Exp 16 (CUDA Streams & PCIe Overlap):** Breadth-first issuing across `4` non-blocking streams with pinned host memory (`cudaMallocHost`) achieves `1.38×` speedup over `1` stream (`34.450 ms` vs. `47.435 ms`).
- **Exp 17 (Atomic Contention & Lock Scaling):** Shared atomic updates cause severe contention (`33.76×` slowdown at `4,096` GPU blocks; high multi-thread overhead on CPU) compared to private/reduction accumulation.
- **Exp 18 (Roofline Model):** Transitions from memory-bandwidth-bound execution at low Arithmetic Intensity (`0.25–2.00` FLOPs/byte) toward compute-bound execution reaching `5,944.31 GFLOP/s` at `256.00` FLOPs/byte.
- **Exp 19 (End-to-End vs. Kernel Speedup):** On `16M` floats with `64` FMA steps, the GPU kernel is `335.92×` faster (`0.765 ms` vs. `256.965 ms`), while full end-to-end runtime including allocation and PCIe transfers is `10.92×` faster (`23.526 ms`).
- **Exp 20 (Hardware Architecture Synthesis):** Decision matrix mapping workload characteristics (arithmetic intensity, contention, stream overlap, and end-to-end transfer amortization) to CPU vs. GPU execution.
