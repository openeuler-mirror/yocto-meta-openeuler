/*
 * @file common.c
 *
 * Copyright (c) Technologies Co., Ltd. 2024. All rights reserved.
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

#include "common.h"
#include <errno.h>
#include <limits.h>
#include <stdbool.h>

static inline bool IsInvalidConvert(long num)
{
    return ((num == LONG_MIN) || (num == LONG_MAX)) && (errno == ERANGE);
}

long str_to_num(const char *str)
{
    char *endptr = NULL;
    long num;
    const int number_base = 10;

    if (str == NULL) {
        return RC_ERROR;
    }
    errno = 0;
    num = strtol(str, &endptr, number_base);
    if ((endptr == str) || (*endptr != '\0') || IsInvalidConvert(num)) {
        return RC_ERROR;
    }
    return num;
}