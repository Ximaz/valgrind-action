#include <fcntl.h>

int main(void)
{
    int fd = open("my_file.txt", O_CREAT | O_WRONLY);

    return 0;
}
