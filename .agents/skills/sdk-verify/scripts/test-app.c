#include <stdio.h>
#include <unistd.h>

int main(void)
{
    printf("Hello from SDK-built C program (pid %d)\n", getpid());
    return 0;
}
