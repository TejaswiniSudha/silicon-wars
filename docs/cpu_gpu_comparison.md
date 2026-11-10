# CPU vs GPU Performance Comparison

## 1. Objective
To compare CPU and GPU execution times using vector addition and matrix multiplication.

## 2. Hardware
- CPU: AMD Ryzen 9 8940HX
- CPU cores: 16 physical cores, 32 logical CPUs
- GPU: NVIDIA GeForce RTX 5050 Laptop GPU
- GPU architecture: Blackwell
- CUDA Toolkit: 13.1
- GPU Streaming Multiprocessors: 20

## 3. Experiment A: Vector Addition
- Input size: 10,000,000 elements
- Operation: C[i] = A[i] + B[i]
- CPU average: 5.84 ms
- GPU average: 4.94 ms
- GPU speedup: 1.18x
- Verified output: 4

## 4. Experiment B: Matrix Multiplication
- Matrix dimensions: 512 x 512
- Operation: C = A x B
- CPU average: 129.78 ms
- GPU average: 6.38 ms
- GPU speedup: 20.34x
- Verified first output element: 1024

The first GPU execution took 364.745 ms and was excluded from the steady-state average because it included substantial first-run initialization overhead.

## 5. Performance Summary

| Experiment | CPU (ms) | GPU (ms) | Speedup |
|---|---:|---:|---:|
| Vector Addition | 5.84 | 4.94 | 1.18x |
| Matrix Multiplication | 129.78 | 6.38 | 20.34x |

## 6. Analysis
Vector addition showed a relatively small GPU advantage because each element requires very little computation. GPU launch overhead becomes significant for such simple operations.

Matrix multiplication showed a much larger GPU advantage because thousands of independent output elements can be calculated in parallel.

These experiments demonstrate that GPU acceleration depends on the nature of the workload and the amount of parallel computation available.

## 7. Timing Methodology and Limitations
- Both programs were compiled using NVCC with -O3 optimization.
- CPU timing covers the computation loops.
- GPU timing covers kernel launch and device synchronization.
- GPU memory allocation and host-to-device/device-to-host transfers are excluded.
- Results are preliminary and may vary with system load, temperature and power settings.
- The matrix multiplication kernel uses a basic implementation without shared-memory tiling.

## 8. Conclusion
The experiments demonstrate that CPUs are effective for general-purpose sequential work, while GPUs can provide substantial acceleration for highly parallel workloads. Matrix multiplication benefited much more from GPU execution than vector addition in these tests.
