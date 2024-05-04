#include <stdlib.h>

int main(void)
{
    int *ptr = NULL;

    ptr = realloc(ptr, 0);
    return 0;
}
