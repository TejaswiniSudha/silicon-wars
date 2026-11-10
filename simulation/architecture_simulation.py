
import matplotlib.pyplot as plt
import numpy as np

# Hardware configuration
CPU_CORES = 16
GPU_SMS = 20
BLOCKS_PER_SM = 4


def simulate_cpu(tasks):
    rounds = int(np.ceil(tasks / CPU_CORES))
    allocation = np.zeros((CPU_CORES, rounds))

    for task in range(tasks):
        core = task % CPU_CORES
        round_no = task // CPU_CORES
        allocation[core, round_no] = 1

    return allocation, rounds


def simulate_gpu(tasks):
    capacity = GPU_SMS * BLOCKS_PER_SM
    rounds = int(np.ceil(tasks / capacity))
    allocation = np.zeros((GPU_SMS, rounds))

    for task in range(tasks):
        sm = (task // BLOCKS_PER_SM) % GPU_SMS
        round_no = task // capacity
        allocation[sm, round_no] += 1

    return allocation, rounds


def draw_simulation(ax, allocation, title, ylabel):
    image = ax.imshow(
        allocation,
        aspect="auto",
        cmap="YlGnBu",
        vmin=0,
        vmax=BLOCKS_PER_SM,
        interpolation="nearest"
    )

    ax.set_title(title, fontsize=13, fontweight="bold")
    ax.set_xlabel("Scheduling Round")
    ax.set_ylabel(ylabel)

    ax.set_xticks(range(allocation.shape[1]))
    ax.set_yticks(range(allocation.shape[0]))

    ax.set_xticks(
        np.arange(-0.5, allocation.shape[1], 1),
        minor=True
    )
    ax.set_yticks(
        np.arange(-0.5, allocation.shape[0], 1),
        minor=True
    )

    ax.grid(which="minor", color="white", linewidth=0.5)
    ax.tick_params(which="minor", bottom=False, left=False)

    plt.colorbar(image, ax=ax, label="Assigned work units")


# Get workload from user
while True:
    try:
        TOTAL_TASKS = int(input("Enter number of work units: "))

        if TOTAL_TASKS <= 0:
            print("Please enter a positive number.")
            continue

        break

    except ValueError:
        print("Please enter a valid whole number.")


# Run simulations
cpu_data, cpu_rounds = simulate_cpu(TOTAL_TASKS)
gpu_data, gpu_rounds = simulate_gpu(TOTAL_TASKS)

# Generate comparison graph
fig, axes = plt.subplots(1, 2, figsize=(16, 8))

draw_simulation(
    axes[0], cpu_data,
    "CPU Task Scheduling",
    "CPU Cores"
)

draw_simulation(
    axes[1], gpu_data,
    "GPU Block Scheduling",
    "GPU Streaming Multiprocessors"
)

fig.suptitle(
    f"CPU vs GPU Simulation ({TOTAL_TASKS} Work Units)",
    fontsize=16,
    fontweight="bold"
)

plt.tight_layout()

plt.savefig(
    "cpu_gpu_simulation.png",
    dpi=300,
    bbox_inches="tight"
)

plt.show()

# Display results
print("\nSIMULATION SUMMARY")
print("----------------------------")
print(f"Total work units: {TOTAL_TASKS}")
print(f"CPU cores: {CPU_CORES}")
print(f"CPU scheduling rounds: {cpu_rounds}")
print(f"GPU SMs: {GPU_SMS}")
print(f"Assumed blocks per SM: {BLOCKS_PER_SM}")
print(f"GPU scheduling rounds: {gpu_rounds}")
print("\nSimulation completed successfully.")
