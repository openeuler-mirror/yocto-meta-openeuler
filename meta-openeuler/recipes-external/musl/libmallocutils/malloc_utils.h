#ifndef MALLOC_UTILS_H
#define MALLOC_UTILS_H

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

#define M_TRIM_THRESHOLD    -1
#define M_TOP_PAD           -2
#define M_MMAP_THRESHOLD    -3
#define M_ARENA_TEST        -7

int mallopt(int param, int value);
int malloc_trim(size_t pad);

#ifdef __cplusplus
}
#endif

#endif /* MALLOC_UTILS_H */
