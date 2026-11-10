# Experiment 3: Measuring CPU Execution Time

## Objective
To compare the execution time of a C program compiled with different optimization levels (-O0 and -O3).

## System Configuration
- Processor: AMD Ryzen 9 8940HX
- CPU Cores: 16
- Threads: 32
- RAM: 16 GB
- Operating System: Ubuntu 26.04 (WSL2)
- Compiler: GCC

## Experimental Setup
A C program was written to calculate the sum of integers from 0 to 1,000,000,000 using a loop.

The program was compiled using:
- -O0: No compiler optimization
- -O3: High-level compiler optimization

Each version was executed three times to obtain more reliable measurements.

## Execution Time Results

| Optimization | Run 1 (s) | Run 2 (s) | Run 3 (s) | Average (s) |
|---|---:|---:|---:|---:|
| -O0 | 1.2820 | 1.3152 | 1.3034 | 1.3002 |
| -O3 | 0.4958 | 0.5318 | 0.5543 | 0.5273 |

## Observations
1. Both versions produced the same final sum: 499999999500000000.
2. The -O3 version consistently executed faster than the -O0 version.
3. The average execution time decreased from 1.3002 seconds to 0.5273 seconds.

## Performance Analysis

Speedup = Average time with -O0 / Average time with -O3

Speedup = 1.3002 / 0.5273 = 2.47x

Percentage reduction in execution time:

= ((1.3002 - 0.5273) / 1.3002) × 100

= 59.44%

## Conclusion
Compiler optimization has a significant effect on CPU execution time. In this experiment, the program compiled with -O3 was approximately 2.47 times faster than the program compiled with -O0. Both versions produced the same result, demonstrating that optimization improved performance without changing the program's output.
