/*
 * @file common.h
 *
 * Copyright (c) Technologies Co., Ltd. 2024-2024. All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 and
 * only version 2 as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 */

#ifndef DTBTOOL_COMMON_H
#define DTBTOOL_COMMON_H

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <dirent.h>
#include <unistd.h>
#include "log_print.h"

#define RC_SUCCESS 0
#define RC_ERROR (-1)
#define DTB_FILE_EXTENSION ".dtb"

#define CHECK_NULL_PTR(PTR, ACTION) do {                            \
    if ((PTR) == NULL) {                                            \
        log_err("Invalid ptr parameter [" #PTR "](NULL).");         \
        ACTION;                                                     \
    }                                                               \
} while (0)

#define SAFE_FREE(PTR) do {   \
    if ((PTR) != NULL) {      \
        free((PTR));          \
        (PTR) = NULL;         \
    }                         \
} while (0)

#define SAFE_PCLOSE(PTR) do {   \
    if ((PTR) != NULL) {        \
        (void)pclose((PTR));    \
        (PTR) = NULL;           \
    }                           \
} while (0)

#define SAFE_CLOSE_DIR(PTR) do {   \
    if ((void*)(PTR) != NULL) {    \
        (void)closedir((PTR));     \
        (PTR) = NULL;              \
    }                              \
} while (0)

#define SAFE_FCLOSE(PTR) do {   \
    if ((PTR) != NULL) {        \
        (void)fclose((PTR));    \
        (PTR) = NULL;           \
    }                           \
} while (0)

#define SAFE_CLOSE(FD) do {   \
    if ((FD) != -1) {         \
        (void)close((FD));    \
        (FD) = -1;            \
    }                         \
} while (0)

long str_to_num(const char *str);

#endif