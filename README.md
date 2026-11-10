# Silicon Wars: Inside the CPU vs GPU Architecture

## Project Overview
A practical study of CPU and GPU architecture, instruction optimization, CUDA programming, and performance comparison.

## Hardware
- CPU: AMD Ryzen 9 8940HX (16 cores, 32 threads)
- GPU: NVIDIA RTX 5050 Laptop GPU (Blackwell)
- CUDA Toolkit: 13.1
- Environment: Ubuntu 26.04.1 LTS on WSL2
- Languages: C, C++, CUDA C++

## Experiments
1. CPU instruction optimization (-O0 vs -O3)
2. CPU performance benchmarking
3. CPU and GPU hardware inspection
4. First CUDA program
5. Vector addition (10 million elements)
6. Matrix multiplication (512 x 512)

## Benchmark Results

| Experiment | CPU Time | GPU Time | Speedup |
|---|---:|---:|---:|
| Vector Addition | 5.84 ms | 4.94 ms | 1.18x |
| Matrix Multiplication | 129.78 ms | 6.38 ms | 20.34x |

## Performance Graphs
See the `docs/` directory:
- cpu_gpu_comparison.png
- gpu_speedup.png

## Conclusion
The experiments demonstrate that CPUs are effective for general-purpose processing, while GPUs offer significant acceleration for highly parallel workloads. The performance advantage depends on the nature of the computation.
  ## CPU vs GPU Architecture Simulation

A Python-based conceptual simulation was developed to visualize workload distribution across CPU cores and GPU Streaming Multiprocessors.

### Simulation Results

| Work Units | CPU Scheduling Rounds | GPU Scheduling Rounds |
|---:|---:|---:|
| 160 | 10 | 2 |
| 320 | 20 | 4 |
| 640 | 40 | 8 |

### Simulation Graphs

Available in the `docs/` directory:

- `cpu_gpu_simulation_160.png`
- `cpu_gpu_simulation.png` (320 work units)
- `cpu_gpu_simulation_640.png`

### Tools Used
- Python
- NumPy
- Matplotlib

The simulation is a conceptual scheduling model, not a cycle-accurate hardware simulation. Its scheduling rounds do not represent actual execution time or measured speedup.

Detailed methodology and limitations are documented in `docs/cpu_gpu_simulation_report.md`.
