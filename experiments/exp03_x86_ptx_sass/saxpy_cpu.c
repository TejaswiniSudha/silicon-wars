#include <stdio.h>

void saxpy_cpu(int n, float a, const float * restrict x, float * restrict y) {
    for (int i = 0; i < n; i++) {
        y[i] = a * x[i] + y[i];
    }
}

int main() {
    float x[4] = {1.0f, 2.0f, 3.0f, 4.0f};
    float y[4] = {10.0f, 20.0f, 30.0f, 40.0f};
    saxpy_cpu(4, 2.0f, x, y);

    printf("y[0]=%.1f, y[3]=%.1f\n", y[0], y[3]);
    return 0;
}
