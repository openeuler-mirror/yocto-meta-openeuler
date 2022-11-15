#include <stddef.h>

int mallopt(int param_number, int value)
{
    /* This concept doesn't really map to musl's malloc */
    return 1;
}

int malloc_trim(size_t pad)
{
    /* This concept doesn't really map to musl's malloc */
    return 1;
}
