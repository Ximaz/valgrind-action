#include <stdlib.h>

int main(void)
{
    int var = 0;

    free(&var);
    return 0;
}
