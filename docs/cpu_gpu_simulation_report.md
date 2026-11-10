
# CPU vs GPU Architecture Simulation Report

## 1. Objective

To develop a conceptual simulation demonstrating how independent work units can be distributed across CPU cores and GPU Streaming Multiprocessors (SMs).

## 2. Hardware Configuration

### CPU Model
- Processor: AMD Ryzen 9 8940HX
- Physical CPU cores: 16
- Logical CPUs: 32

### GPU Model
- GPU: NVIDIA GeForce RTX 5050 Laptop GPU
- Streaming Multiprocessors: 20
- Assumed concurrent blocks per SM: 4

Note: The four-block capacity is a simulation assumption and is not a measured hardware occupancy limit.

## 3. Simulation Environment

- Programming language: Python
- Visualization library: Matplotlib
- Numerical library: NumPy

The simulation represents CPU cores and GPU SMs as separate processing resources.

## 4. Methodology

The simulation distributes independent work units using two conceptual scheduling models.

### CPU Scheduling

- 16 CPU cores are modelled.
- Each core receives one work unit per scheduling round.
- A new round begins after all available cores receive their assigned work.

### GPU Scheduling

- 20 GPU Streaming Multiprocessors are modelled.
- Each SM is assumed to receive four CUDA thread blocks per scheduling round.
- The model processes 80 blocks per round across all SMs.

## 5. Simulation Results

| Work Units | CPU Rounds | GPU Rounds |
|---:|---:|---:|
| 160 | 10 | 2 |
| 320 | 20 | 4 |
| 640 | 40 | 8 |

## 6. Observations

1. Increasing the workload increases the number of scheduling rounds in both models.
2. The GPU model distributes work across 20 SMs, with four blocks assigned to each SM per round.
3. The CPU model distributes one work unit to each of its 16 cores per round.
4. The number of scheduling rounds differs because the two models use different assumed scheduling capacities.

## 7. Limitations

- This is a conceptual scheduling simulation, not a cycle-accurate hardware simulator.
- CPU and GPU work units represent different execution abstractions.
- The assumed four concurrent blocks per SM are not a verified hardware limit.
- The simulation does not model instruction execution, memory latency, cache behaviour, synchronization, or actual hardware occupancy.
- Scheduling rounds must not be interpreted as real execution time or measured performance speedup.

## 8. Conclusion

The simulation visually demonstrates two different approaches to distributing parallel workloads. The CPU model assigns work across physical cores, while the GPU model distributes thread blocks across Streaming Multiprocessors.

Together with the actual CUDA benchmark experiments, this simulation helps illustrate the architectural differences between CPU and GPU processing.
