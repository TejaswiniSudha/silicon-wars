# Experiment 3: x86-64 vs PTX vs SASS (SAXPY)

## 1. Goal
Implement SAXPY (`y[i] = a * x[i] + y[i]`) on both the CPU (AMD Ryzen 9 8940HX) and GPU (NVIDIA RTX 5050 Laptop GPU) to inspect and compare three instruction layers: x86-64 AVX2/FMA assembly, NVIDIA PTX virtual ISA, and NVIDIA SASS hardware machine code.

## 2. COA Concepts
- **SIMD (Single Instruction, Multiple Data):** CPU execution model where a single thread loops over an array, processing multiple elements simultaneously inside wide vector registers (256-bit `ymm` registers = 8 floats).
- **SIMT (Single Instruction, Multiple Threads):** GPU execution model where thousands of lightweight threads each compute a single element (`i = blockIdx.x * blockDim.x + threadIdx.x`), grouped into 32-thread warps executed in lockstep.
- **PTX (Parallel Thread Execution):** NVIDIA's portable, virtual GPU assembly language using typed virtual registers (`%r`, `%f`, `%rd`, `%p`).
- **SASS (Streaming ASSembler):** Hardware-specific GPU machine code with fixed-width 128-bit (16-byte) instructions and physical registers (`R0`–`R7`, `P0`).
- **FMA (Fused Multiply-Add):** A single hardware instruction (`vfmadd213ps` on CPU, `fma.rn.f32` in PTX, `FFMA` in SASS) that computes `a * x + y` without intermediate rounding.

## 3. Method
1. Implemented CPU SAXPY in `saxpy_cpu.c` using the `restrict` keyword to enable safe auto-vectorization.
2. Compiled and verified `saxpy_cpu.c` with `gcc -O3 -mavx2 -mfma`, then generated Intel-syntax x86-64 assembly (`saxpy_cpu.s`).
3. Implemented GPU SAXPY in `saxpy_gpu.cu` as a CUDA `__global__` kernel.
4. Compiled and verified `saxpy_gpu.cu` on the RTX 5050 with `nvcc -O3`.
5. Extracted PTX virtual assembly using `nvcc -O3 -ptx` (`saxpy_gpu.ptx`).
6. Disassembled the compiled CUDA binary with `cuobjdump -sass` to inspect the actual SASS machine instructions (`saxpy_gpu.sass`).
7. Recorded the architectural comparison in `results.csv`.

## 4. Commands

    # CPU: compile, verify, and generate x86-64 assembly
    gcc -O3 -mavx2 -mfma saxpy_cpu.c -o saxpy_cpu
    ./saxpy_cpu
    gcc -O3 -mavx2 -mfma -S -masm=intel saxpy_cpu.c -o saxpy_cpu.s
    grep -A 35 "^saxpy_cpu:" saxpy_cpu.s

    # GPU: compile, verify, and extract PTX and SASS
    nvcc -O3 saxpy_gpu.cu -o saxpy_gpu
    ./saxpy_gpu
    nvcc -O3 -ptx saxpy_gpu.cu -o saxpy_gpu.ptx
    grep -A 45 "\.visible \.entry" saxpy_gpu.ptx
    cuobjdump -sass saxpy_gpu > saxpy_gpu.sass
    cat saxpy_gpu.sass

## 5. Results
Both CPU and GPU executions produced identical verified output:

    y[0]=12.0, y[3]=48.0

Structured comparison data is saved in `results.csv`.

## 6. Three-Layer Comparison Table

| Layer | Target Hardware | Execution Model | Instruction Width | Registers Used | Loop Structure | FMA Instruction | Memory Access |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **x86-64** | AMD Ryzen 9 8940HX (CPU) | SIMD (8 floats/vector) | Variable (1–15 bytes) | Physical 256-bit `ymm0`/`ymm1` | Explicit loop (`.L4` advancing 32 bytes) | `vfmadd213ps` | `vmovups` (RAM/Cache) |
| **PTX** | Virtual NVIDIA GPU ISA | SIMT (1 element/thread) | Textual Virtual ISA | Virtual typed (`%r`, `%f`, `%rd`, `%p`) | No loop (thread ID + bounds check) | `fma.rn.f32` | `ld.global.f32` / `st.global.f32` |
| **SASS** | NVIDIA GPU (`sm_75` default / JIT to Blackwell) | SIMT (32-thread warps) | Fixed 128-bit (16 bytes) | Physical 32-bit (`R0`–`R7`, `P0`) + `c[0x0]` | No loop (predicated `@P0 EXIT`) | `FFMA` | `LDG.E.SYS` / `STG.E.SYS` |

## 7. Explanation of Results
- **Loop vs. Thread Grid:** On the CPU, `saxpy_cpu` broadcasts `a` into `ymm1` (`vbroadcastss`) and loops over memory 32 bytes (8 floats) at a time using `vfmadd213ps`. On the GPU, the loop disappears entirely: each thread computes its index via `IMAD` from `SR_CTAID.X` and `SR_TID.X`, exits early if `i >= n` (`@P0 EXIT`), and executes a single `FFMA`.
- **Virtual vs. Physical ISA:** PTX abstracts away hardware details using virtual registers and generic parameter loads (`ld.param`). SASS maps those onto physical registers (`R2`, `R3`, `R4`, `R7`), reads kernel arguments directly from constant memory (`c[0x0][...]`), and uses fixed 16-byte instruction words (offsets `0000`, `0010`, `0020`, ...).
- **JIT Compilation:** Compiling with default `nvcc` flags produced `sm_75` SASS alongside embedded PTX, which the NVIDIA driver JIT-compiles at runtime for the RTX 5050 (Blackwell).

## 8. Limitations
- This experiment inspects static instruction sets and verifies correctness on a 4-element array rather than measuring runtime throughput or memory bandwidth.
- Default `nvcc` flags targeted `sm_75` for the static SASS dump; specifying a Blackwell-specific `-arch` flag would show architecture-specific Blackwell SASS encodings directly.
