#include <stdio.h>
#include <time.h>

int main() {
    volatile long long sum = 0;
    clock_t start, end;

    start = clock();

    for (long long i = 0; i < 1000000000LL; i++) {
        sum += i;
    }

    end = clock();

    double cpu_time = (double)(end - start) / CLOCKS_PER_SEC;

    printf("Final Sum: %lld\n", sum);
    printf("CPU Execution Time: %.4f seconds\n", cpu_time);

    return 0;
}
