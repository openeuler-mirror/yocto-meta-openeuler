/*
 * @file log_print.h
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

#ifndef DTBTOOL_LOG_PRINT_H
#define DTBTOOL_LOG_PRINT_H

#define log_err(x...) (void)printf(x)
#define log_info(x...) (void)printf(x)
#define log_dbg(x...) do { \
    if (verbose != 0) { \
        (void)printf(x); \
    } \
} while (0)

#endif