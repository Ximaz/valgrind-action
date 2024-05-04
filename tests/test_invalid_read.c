#include <stdlib.h>

int main(void)
{
    int *a = malloc(1);

    a[0] = a[1];
    free(a);
    return 0;
}
