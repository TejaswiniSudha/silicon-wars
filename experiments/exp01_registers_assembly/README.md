# Experiment 1: Registers and Assembly (-O0 vs -O3 vs -O3 -mavx2)

## 1. Goal
Investigate how GCC translates C functions into x86-64 assembly across different optimization levels (`-O0`, `-O3`, and `-O3 -mavx2`), focusing on register usage, stack memory accesses, branch elimination, and SIMD auto-vectorization on an AMD Ryzen 9 8940HX.

## 2. COA Concepts
- **Registers vs. Stack Memory:** CPU registers (`eax`, `edi`, `esi`) are ultra-fast internal storage, whereas stack memory (`[rbp-4]`) resides in RAM/cache and requires load/store instructions.
- **Calling Conventions (System V AMD64 ABI):** Integer arguments arrive in `edi`, `esi`, `edx`, and return values are placed in `eax`.
- **Branchless Execution:** Replacing conditional jumps (`jle`) with conditional moves (`cmovl`, `cmovge`) eliminates branch misprediction penalties.
- **SIMD (Single Instruction, Multiple Data):** Vector registers (`xmm` 128-bit SSE2, `ymm` 256-bit AVX2) process multiple integers in parallel within a single instruction.

## 3. Method
1. Implemented three C functions in `functions.c`:
   - `add(int a, int b)` — simple arithmetic
   - `sum(int *arr, int n)` — array reduction loop
   - `max3(int a, int b, int c)` — conditional branching
2. Compiled and executed `functions.c` with `-O0` to verify functional correctness.
3. Generated Intel-syntax assembly files using `-O0`, `-O3`, and `-O3 -mavx2`.
4. Inspected and compared the generated instructions for each function.

## 4. Commands

    # Compile and verify correctness
    gcc -O0 functions.c -o functions_O0
    ./functions_O0

    # Generate assembly files
    gcc -O0 -S -masm=intel functions.c -o functions_O0.s
    gcc -O3 -S -masm=intel functions.c -o functions_O3.s
    gcc -O3 -mavx2 -S -masm=intel functions.c -o functions_O3_avx2.s

    # Inspect specific functions
    grep -A 15 "^add:" functions_O0.s
    grep -A 10 "^add:" functions_O3.s
    grep -A 25 "^max3:" functions_O0.s
    grep -A 15 "^max3:" functions_O3.s
    grep -A 28 "^sum:" functions_O0.s
    grep -A 45 "^sum:" functions_O3.s
    grep -A 45 "^sum:" functions_O3_avx2.s

## 5. Results
Program verification output (`./functions_O0`):

    Addition: 30
    Array Sum: 150
    Maximum: 25

Structured comparison is saved in `results.csv`.

## 6. Comparison Table

| Function | Optimization | Stack Frame | Register Type | Elements / Loop | Key Instruction(s) | Optimization Behavior |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `add` | `-O0` | Yes | 32-bit GPR | N/A | `add` | 4 unnecessary stack memory accesses |
| `add` | `-O3` | No | 64/32-bit GPR | N/A | `lea` | Zero memory accesses; single-instruction addition |
| `add` | `-O3 -mavx2` | No | 64/32-bit GPR | N/A | `lea` | Same as `-O3` (scalar function) |
| `max3` | `-O0` | Yes | 32-bit GPR | N/A | `cmp` + `jle` | Stack spills and 2 conditional branches |
| `max3` | `-O3` | No | 32-bit GPR | N/A | `cmovl` + `cmovge` | Branchless execution using conditional moves |
| `max3` | `-O3 -mavx2` | No | 32-bit GPR | N/A | `cmovl` + `cmovge` | Same as `-O3` (scalar function) |
| `sum` | `-O0` | Yes | 32-bit GPR | 1 int (4 bytes) | `add` | Scalar loop with stack memory accesses |
| `sum` | `-O3` | No | 128-bit SSE2 (`xmm`) | 4 ints (16 bytes) | `movdqu` + `paddd` | 128-bit SIMD auto-vectorization |
| `sum` | `-O3 -mavx2` | No | 256-bit AVX2 (`ymm`) | 8 ints (32 bytes) | `vpaddd` | 256-bit SIMD auto-vectorization with fused load-add |

## 7. Explanation of Results
- **`add()`:** At `-O0`, GCC sets up a stack frame (`push rbp`), spills `edi` and `esi` to the stack, and immediately reloads them. At `-O3`, GCC eliminates the stack frame completely and uses `lea eax, [rdi+rsi]` to compute the sum in a single instruction with zero memory traffic.
- **`max3()`:** At `-O0`, GCC emits two conditional jumps (`jle`), which can cause branch mispredictions. At `-O3`, GCC converts the logic into branchless code using `cmovl` and `cmovge`.
- **`sum()`:** At `-O0`, the loop processes 1 integer per iteration using scalar registers and stack variables. At `-O3`, GCC auto-vectorizes the loop using 128-bit `xmm` registers (`paddd`) to sum 4 integers per iteration. Adding `-mavx2` unlocks 256-bit `ymm` registers (`vpaddd`), summing 8 integers per iteration with a fused memory load-and-add instruction.

## 8. Limitations
- This experiment inspects static compiler-generated assembly rather than measuring runtime execution speed or CPU cycles.
- The test array in `main()` only has 5 elements, which is too small to trigger the 8-element AVX2 main loop at runtime (it would execute the scalar/SSE cleanup tail instead). Runtime performance and SIMD speedup will be measured directly in later experiments.
