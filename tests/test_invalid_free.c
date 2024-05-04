#include <stdlib.h>

int main(void)
{
    int *var = malloc(1);

    free(var);
    free(var);
    return 0;
}
