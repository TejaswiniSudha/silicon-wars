# Silicon Wars: Inside the CPU vs. GPU Architecture

A hands-on, experimentally driven Computer Organization and Architecture (COA) project comparing modern x86-64 CPU and NVIDIA GPU microarchitectures from bare-metal instruction encoding up to memory hierarchies, matrix multiplication, control-flow hazards, and PCIe interconnects.

## Hardware & Environment
- **CPU:** AMD Ryzen 9 8940HX (x86-64, AVX2 + FMA)
- **GPU:** NVIDIA GeForce RTX 5050 Laptop GPU (Blackwell, CUDA)
- **OS & Toolchain:** Windows 11 / WSL2 Ubuntu 26.04.1 LTS, `gcc`, `g++`, `nvcc`, `make`, Python (`matplotlib`)

## Experiments Summary

| # | Experiment | Core COA Concept | Key Experimental Finding |
| :--- | :--- | :--- | :--- |
| **1** | [Registers & Assembly](experiments/exp01_registers_assembly) | Register allocation, stack spills, `lea`, `cmov`, AVX2 | Observed compiler optimization eliminating stack spills and vectorizing scalar loops with 256-bit AVX2. |
| **2** | [Instruction Encoding](experiments/exp02_instruction_encoding) | x86-64 machine code, opcodes, ModR/M, REX.W (`0x48`), Little-Endian | Decoded raw binary instruction bytes and verified variable-length x86-64 encoding. |
| **3** | [x86 vs. PTX vs. SASS](experiments/exp03_x86_ptx_sass) | CISC/SIMD vs. Virtual SIMT ISA vs. Physical GPU Machine Code | Compared SAXPY across x86 AVX2/FMA, virtual PTX, and 16-byte physical SASS instructions. |
| **4** | [CPU Cache Hierarchy](experiments/exp04_cache_hierarchy) | L1 / L2 / L3 / RAM latency via random pointer-chasing | Measured distinct latency plateaus across the Ryzen 9 8940HX cache hierarchy (`cache_latency.png`). |
| **5** | [CPU Matrix Multiplication](experiments/exp05_matmul_tiling) | Row-major spatial locality, loop reordering, cache tiling | Reordering `i-j-k` → `i-k-j` achieved an **11.1× speedup** (`1123.90 ms` → `101.33 ms`, **21.19 GFLOP/s**). |
| **6** | [GPU Matrix Multiplication](experiments/exp06_gpu_matmul) | SIMT parallelism, Global VRAM vs. Shared-Memory (`__shared__`) tiling | Shared-memory tiling reached **1019.64 GFLOP/s** (`2.106 ms`) — **48.1× faster** than best single-threaded CPU. |
| **7** | [Branch Prediction vs. Warp Divergence](experiments/exp07_branch_vs_divergence) | CPU pipeline flushes vs. GPU 32-thread lockstep serialization | Unsorted data caused a **7.58× CPU penalty** (`1.416` → `10.738 ms`); warp divergence caused a **1.61× GPU penalty** (`0.234` → `0.377 ms`). |
| **8** | [The PCIe Bottleneck](experiments/exp08_pcie_bottleneck) | Host-to-Device / Device-to-Host DMA, Pageable vs. Pinned RAM | Pinned memory hit **14.27 GB/s** (H2D) and **14.24 GB/s** (D2H), **1.50×–1.67× faster** than pageable memory (`9.50` / `8.54 GB/s`). |

## Repository Structure
Each experiment folder is self-contained and includes:
- Source code (`.c` / `.cu`)
- Raw benchmark dataset (`results.csv`)
- Plotting script (`.py`) and generated chart (`.png`)
- Detailed write-up (`README.md`) with methodology, commands, and architectural analysis
