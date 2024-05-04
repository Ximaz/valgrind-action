#include <stdlib.h>

int main(void)
{
    int *a = malloc(1);

    a[1] = '0';
    free(a);
    return 0;
}
