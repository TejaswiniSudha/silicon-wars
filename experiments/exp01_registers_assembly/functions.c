#include <stdio.h>

// Function 1: Addition
int add(int a, int b) {
    return a + b;
}

// Function 2: Sum of array elements
int sum(int *arr, int n) {
    int s = 0;

    for (int i = 0; i < n; i++) {
        s += arr[i];
    }

    return s;
}

// Function 3: Find maximum of three numbers
int max3(int a, int b, int c) {
    int m = a;

    if (b > m)
        m = b;

    if (c > m)
        m = c;

    return m;
}

int main() {
    int arr[] = {10, 20, 30, 40, 50};

    printf("Addition: %d\n", add(10, 20));
    printf("Array Sum: %d\n", sum(arr, 5));
    printf("Maximum: %d\n", max3(15, 25, 10));

    return 0;
}
