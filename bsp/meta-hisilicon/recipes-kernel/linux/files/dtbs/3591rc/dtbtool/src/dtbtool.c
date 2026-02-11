/*
 * @file dtbool.c
 *
 * Copyright (c) Technologies Co., Ltd. 2018-2024. All rights reserved.
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

#define _GNU_SOURCE
#include "securec.h"
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <getopt.h>
#include <unistd.h>
#include <errno.h>
#include <limits.h>
#include "log_print.h"
#include "common.h"

#define HSDT_MAGIC "HSDT" /* Master DTB magic */
#define HSDT_VERSION 1    /* HSDT version */

#define HSDT_DT_TAG "hisi,boardid = <"

#define PAGE_SIZE_DEF 2048
#define PAGE_SIZE_MAX (1024 * 1024)

#define COPY_BLK 1024 /* File copy block size */

#define MIN_BOARD_ADC_COUNT 4
#define MAX_BOARD_ADC_COUNT 8

#define FIRST_BOARDID_INDEX  0
#define SECOND_BOARDID_INDEX 1
#define THIRD_BOARDID_INDEX  2
#define FOURTH_BOARDID_INDEX 3

#define FIRST_BOARDID_BIT  7
#define SECOND_BOARDID_BIT 16
#define THIRD_BOARDID_BIT  8

#define DEC_FLAG 9

typedef struct dt_entry_t {
    uint8_t boardid[MIN_BOARD_ADC_COUNT];
    uint8_t reserved[4];
    uint32_t dtb_size;
    uint32_t vrl_size;
    uint32_t dtb_offset;
    uint32_t vrl_offset;
    uint64_t dtb_file;
    uint64_t vrl_file;
} dt_entry_t;

typedef struct chipInfo_t {
    struct dt_entry_t dt_entry;
    struct chipInfo_t *prev;
    struct chipInfo_t *next;
} chipInfo_t;

typedef struct dt_table_t {
    uint32_t magic;
    uint32_t version;
    uint32_t num_entries;
} dt_table_t;

struct chipInfo_t *chip_list;

static const char *input_dir = "./";
static const char *output_file = NULL;
static const char *dtc_path = "";
int verbose;
static uint32_t page_size = PAGE_SIZE_DEF;

static void print_help(void)
{
    log_info("dtbTool [options] -o <output file> <input DTB path>\n");
    log_info("  options:\n");
    log_info("  --output-file/-o     output file\n");
    log_info("  --dtc-path/-p        path to dtc\n");
    log_info("  --page-size/-s       page size in bytes\n");
    log_info("  --verbose/-v         verbose\n");
    log_info("  --help/-h            this help screen\n");
}

static const struct option g_long_options[] = {
    {"output-file", 1, NULL, 'o'},
    {"dtc-path",    1, NULL, 'p'},
    {"page-size",   1, NULL, 's'},
    {"verbose",     0, NULL, 'v'},
    {"help",        0, NULL, 'h'},
    {NULL,          0, NULL, 0}
};

static inline bool IsInvalidPageSize(long num)
{
    return (num <= 0) || (num > PAGE_SIZE_MAX);
}

static bool SetInputValue(const int c)
{
    long num;
    bool ret = true;
    switch (c) {
        case 1:
            input_dir = optarg;
            break;
        case 'o':
            output_file = optarg;
            break;
        case 'p':
            dtc_path = optarg;
            break;
        case 's':
            num = str_to_num(optarg);
            if (IsInvalidPageSize(num)) {
                log_err("Invalid page size (> 0 and <=1MB, page_size = %lu\n", num);
                return false;
            }
            page_size = (uint32_t)num;
            break;
        case 'v':
            verbose = 1;
            break;
        default:
            ret = false;
            break;
    }
    if (output_file == NULL) {
        log_err("Output file must be specified\n");
        ret = false;
    }
    return ret;
}

static int parse_commandline(int argc, char * const argv[])
{
    bool parse_result = true;
    while (1) {
        int c = getopt_long(argc, argv, "-o:p:s:vh", g_long_options, NULL);
        if (c == -1) {
            break;
        }
        parse_result = SetInputValue(c);
    }
    if (!parse_result) {
        return RC_ERROR;
    }
    return RC_SUCCESS;
}

/**
 * @brief       : insert c in front of x
 * @param [in]  : struct chipInfo_t *c  added node
 * @param [in]  : struct chipInfo_t *x  current node
 * @return      : RC_SUCCESS: succeed; RC_ERROR: failed
 */
static int ChipListInsert(struct chipInfo_t *c, struct chipInfo_t *x)
{
    CHECK_NULL_PTR(c, return RC_ERROR);
    CHECK_NULL_PTR(x, return RC_ERROR);
    if (x->prev == NULL) {
        c->next = x;
        c->prev = NULL;
        x->prev = c;
        chip_list = c;
        return RC_SUCCESS;
    }
    c->next = x;
    c->prev = x->prev;
    x->prev->next = c;
    x->prev = c;
    return RC_SUCCESS;
}

static inline bool IsBoardidMatch(const struct chipInfo_t *c, const struct chipInfo_t *x)
{
    return (c->dt_entry.boardid[FIRST_BOARDID_INDEX] == x->dt_entry.boardid[FIRST_BOARDID_INDEX]) && \
           (c->dt_entry.boardid[SECOND_BOARDID_INDEX] == x->dt_entry.boardid[SECOND_BOARDID_INDEX]) && \
           (c->dt_entry.boardid[THIRD_BOARDID_INDEX] == x->dt_entry.boardid[THIRD_BOARDID_INDEX]) && \
           (c->dt_entry.boardid[FOURTH_BOARDID_INDEX] == x->dt_entry.boardid[FOURTH_BOARDID_INDEX]);
}

/**
 * @brief       : compare boardid betweent two node
 * @param [in]  : struct chipInfo_t *c  added node
 * @param [in]  : struct chipInfo_t *x  current node
 * @return      : -1: less; 0: equal; 1: greater
 */
static int BoardidCmp(const struct chipInfo_t *c, const struct chipInfo_t *x)
{
    if ((c->dt_entry.boardid[FIRST_BOARDID_INDEX] < x->dt_entry.boardid[FIRST_BOARDID_INDEX]) ||
        ((c->dt_entry.boardid[FIRST_BOARDID_INDEX] == x->dt_entry.boardid[FIRST_BOARDID_INDEX]) && \
         (c->dt_entry.boardid[SECOND_BOARDID_INDEX] < x->dt_entry.boardid[SECOND_BOARDID_INDEX])) || \
        ((c->dt_entry.boardid[SECOND_BOARDID_INDEX] == x->dt_entry.boardid[SECOND_BOARDID_INDEX]) && \
         (c->dt_entry.boardid[THIRD_BOARDID_INDEX] < x->dt_entry.boardid[THIRD_BOARDID_INDEX]))) {
        return -1;
    }
    if (IsBoardidMatch(c, x)) {
        return 0;
    }
    return 1;
}

/* Unique entry sorted list add (by boardid sort ascending) */
static int chip_add(struct chipInfo_t *c)
{
    struct chipInfo_t *x = chip_list;

    if (chip_list == NULL) {
        chip_list = c;
        c->next = NULL;
        c->prev = NULL;
        return RC_SUCCESS;
    }
    while (1) {
        int ret = BoardidCmp(c, x);
        if (ret < 0) {
            return ChipListInsert(c, x);
        }
        if (ret == 0) {
            return RC_ERROR; /* duplicate */
        }
        if (x->next == NULL) {
            c->prev = x;
            c->next = NULL;
            x->next = c;
            break;
        }
        x = x->next;
    }
    return RC_SUCCESS;
}

static void chip_deleteall(void)
{
    struct chipInfo_t *c = chip_list, *t;

    while (c != NULL) {
        t = c;
        c = c->next;
        free((void*)(uintptr_t)t->dt_entry.dtb_file);
        t->dt_entry.dtb_file = 0;
        free((void*)(uintptr_t)t->dt_entry.vrl_file);
        t->dt_entry.vrl_file = 0;
        SAFE_FREE(t);
    }
}

/**
 * @brief       : splice complete shell cmd, which used to decompile dtb_file
 * @param [in]  : dtc_dir   dir of dtc tool
 * @param [in]  : dtb_file  dtb file path
 * @return      : complete cmd: succeed; NULL: failed
 */
static char *GetDecompileCmd(const char *dtc_dir, const char* dtb_file)
{
    CHECK_NULL_PTR(dtc_dir, return NULL);
    CHECK_NULL_PTR(dtb_file, return NULL);

    const char pre_cmd[] = "dtc -I dtb -O dts \"";
    const char next_cmd[] = "\" 2>&1";

    size_t cmd_len = sizeof(char) * (strlen(dtc_dir) + strlen(pre_cmd) + strlen(dtb_file) + strlen(next_cmd) + 1UL);
    if (cmd_len == 0 || cmd_len >= ULONG_MAX) {
        log_err("Invalid size for malloc\n");
        return NULL;
    }
    char *cmd = (char *)malloc(cmd_len);
    if (cmd == NULL) {
        log_err("Out of memory\n");
        return NULL;
    }

    errno_t ret = strncpy_s(cmd, cmd_len, dtc_dir, strlen(dtc_dir));
    if (ret != EOK) {
        log_err("Str copy fail with %d\n", ret);
        SAFE_FREE(cmd);
        return NULL;
    }
    ret = strncat_s(cmd, cmd_len, pre_cmd, strlen(pre_cmd));
    if (ret != EOK) {
        log_err("Str cat fail with %d\n", ret);
        SAFE_FREE(cmd);
        return NULL;
    }
    ret = strncat_s(cmd, cmd_len, dtb_file, strlen(dtb_file));
    if (ret != EOK) {
        log_err("Str cat fail with %d\n", ret);
        SAFE_FREE(cmd);
        return NULL;
    }
    ret = strncat_s(cmd, cmd_len, next_cmd, strlen(next_cmd));
    if (ret != EOK) {
        log_err("Str cat fail with %d\n", ret);
        SAFE_FREE(cmd);
        return NULL;
    }
    return cmd;
}

/**
 * @brief       : get boardid from string "
 * @param [in]  : p_token        string to parse
 * @param [in]  : boardid        array to save value
 * @param [in]  : boardid_size   sizeof array
 * @param [in]  : cnt            index of array
 * @return      : true: succeed; false: failed
 */
static bool StrToBoardId(char *p_token, uint32_t *boardid, uint8_t boardid_size, uint8_t cnt)
{
    if (cnt >= boardid_size) {
        log_err("Invalid Boardid: boardid length is exceeds limit.\n");
        return false;
    }
    errno = 0;
    unsigned long num = strtoul(p_token, NULL, 0);
    if ((errno != 0) && ((num == 0) || (num == ULONG_MAX))) {
        log_err("Invalid Boardid: string to number fail with %lu.\n", num);
        return false;
    }
    boardid[cnt] = (uint32_t)num;
    return true;
}

static inline bool IsInvalidBoardidLen(uint8_t len, bool isOldDts)
{
    return (len < MIN_BOARD_ADC_COUNT) || (isOldDts && (len > MIN_BOARD_ADC_COUNT));
}

/**
 * @brief       : get boardid from "xx xx xx xx ...>;"
 * @param [in]  : src_str        string to parse
 * @param [in]  : boardid        array to save value
 * @param [in]  : boardid_size   sizeof array
 * @return      : real len of boardid: succeed; 0: failed
 */
static uint8_t ParseBoardid(char *src_str, uint32_t *boardid, uint8_t boardid_size)
{
    CHECK_NULL_PTR(boardid, return false);
    CHECK_NULL_PTR(src_str, return false);
    char *saveptr = NULL;
    uint8_t cnt = 0;
    bool isOldDts = false;
    char *p_token = strtok_r(src_str, " \t", &saveptr);
    while (p_token != NULL) {
        if (!StrToBoardId(p_token, boardid, boardid_size, cnt)) {
            return 0;
        }
        // If boardid in a~f, only support old mode.
        if (boardid[cnt] > DEC_FLAG) {
            log_err("Warning: exists boardid [%d] not in 0~9.\n", boardid[cnt]);
            isOldDts = true;
        }
        cnt++;
        p_token = strtok_r(NULL, " \t", &saveptr);
    }
    if (IsInvalidBoardidLen(cnt, isOldDts)) {
        log_err("Invalid Boardid: boardid length [%d] is not valid.\n", cnt);
        return 0;
    }
    return cnt;
}

/**
 * @brief       : use boardid to set chip value
 * @param [in]  : boardid        array of boardid
 * @param [in]  : boardidSize   real length of array
 * @return      : chipInfo_t node: succeed; NULL: failed
 */
static struct chipInfo_t *SetChipValue(uint32_t *boardid, uint8_t boardidSize)
{
    CHECK_NULL_PTR(boardid, return NULL);

    uint8_t i;
    uint32_t boardidVal = 0;
    struct chipInfo_t *chip = (chipInfo_t *)malloc(sizeof(struct chipInfo_t));
    if (chip == NULL) {
        log_err("Out of memory: malloc failed for chipInfo.\n");
        return NULL;
    }
    (void)memset_s(chip, sizeof(struct chipInfo_t), 0, sizeof(struct chipInfo_t));
 
    if (boardidSize == MIN_BOARD_ADC_COUNT) {
        for (i = 0; i < MIN_BOARD_ADC_COUNT; i++) {
            chip->dt_entry.boardid[i] = (uint8_t)boardid[i];
        }
    } else {
        // set slotid
        chip->dt_entry.boardid[FIRST_BOARDID_INDEX] = (uint8_t)((boardid[0] & 0xffU) | (1U << FIRST_BOARDID_BIT));
 
        // set boardid
        for (i = 1; i < boardidSize; i++) {
            boardidVal = (boardidVal * 10U) + boardid[i];
        }
        chip->dt_entry.boardid[SECOND_BOARDID_INDEX] = (uint8_t)((boardidVal & 0xFF0000U) >> SECOND_BOARDID_BIT);
        chip->dt_entry.boardid[THIRD_BOARDID_INDEX] = (uint8_t)((boardidVal & 0x00FF00U) >> THIRD_BOARDID_BIT);
        chip->dt_entry.boardid[FOURTH_BOARDID_INDEX] = (uint8_t)(boardidVal & 0x0000FFU);
    }
    chip->dt_entry.dtb_size = 0;
    chip->dt_entry.dtb_file = 0;
    chip->dt_entry.vrl_size = 0;
    chip->dt_entry.vrl_file = 0;
    chip->prev = NULL;
    chip->next = NULL;
    return chip;
}

/* Extract 'hisi,boardid' parameter triplet from DTB
      hisi,boardid = <xxx>;
 */
static struct chipInfo_t *getChipInfo(const char *filename)
{
    char *pos;
    size_t lineSize = 1024;
    uint8_t boardidSize = 0;
    uint32_t boardid[MAX_BOARD_ADC_COUNT] = {0, 0, 0, 0, 0, 0, 0, 0};
    struct chipInfo_t *chip = NULL;

    char *cmd = GetDecompileCmd(dtc_path, filename);
    if (cmd == NULL) {
        log_err("Get decompile dtb cmd fail\n");
        return NULL;
    }
    FILE *pfile = popen(cmd, "r");
    SAFE_FREE(cmd);
    if (pfile == NULL) {
        log_err("... skip, fail to decompile dtb\n");
        return NULL;
    }

    char *line = (char *)malloc(lineSize);
    if (line == NULL) {
        log_err("Out of memory\n");
        SAFE_PCLOSE(pfile);
        return NULL;
    }
    /* Find "hisi,boardid = <" */
    while (getline(&line, &lineSize, pfile) != -1) {
        pos = strstr(line, HSDT_DT_TAG);
        if (pos == NULL) {
            continue;
        }
        pos += strlen(HSDT_DT_TAG);
        boardidSize = ParseBoardid(pos, boardid, MAX_BOARD_ADC_COUNT);
        if (boardidSize == 0) {
            log_err("Parse boardid fail.\n");
            break;
        }
        chip = SetChipValue(boardid, boardidSize);
        if (chip == NULL) {
            log_err("Set chip value fail.\n");
            break;
        }
    }

    SAFE_FREE(line);
    SAFE_PCLOSE(pfile);
    return chip;
}

/**
 * @brief       : join file path and name
 * @param [in]  : filePath      file Path
 * @param [in]  : fileName      file name
 * @return      : complete file name: succeed; NULL: failed
 */
static char *GetFullFileName(const char *filePath, char *fileName)
{
    CHECK_NULL_PTR(filePath, return NULL);
    CHECK_NULL_PTR(fileName, return NULL);

    size_t fileLen = strlen(filePath) + strlen(fileName) + 1UL;
    if (fileLen == 0 || fileLen >= ULONG_MAX) {
        log_err("Invalid size for malloc\n");
        return NULL;
    }
    char *fullName = (char *)malloc(fileLen);
    if (fullName == NULL) {
        log_err("Out of memory\n");
        return NULL;
    }
    errno_t ret = strncpy_s(fullName, fileLen, filePath, strlen(filePath));
    if (ret != EOK) {
        SAFE_FREE(fullName);
        log_err("Strncopy_s fail with %d\n", ret);
        return NULL;
    }
    ret = strncat_s(fullName, fileLen, fileName, strlen(fileName));
    if (ret != EOK) {
        SAFE_FREE(fullName);
        log_err("Strncat_s fail with %d\n", ret);
        return NULL;
    }
    return fullName;
}

/**
 * @brief       : get vrl name of dtb file
 * @param [in]  : fileName      dtb file name
 * @param [in]  : nameSize      size of file name
 * @return      : vrl name: succeed; NULL: failed
 */
static char *GetDtbVrlFileName(const char *fileName, size_t nameSize)
{
    CHECK_NULL_PTR(fileName, return NULL);
    if (nameSize == 0 || nameSize >= ULONG_MAX) {
        log_err("Invalid size for malloc\n");
        return NULL;
    }
    char *dtbVrlFileName = (char *)malloc(nameSize);
    if (dtbVrlFileName == NULL) {
        log_err("Out of memory\n");
        return NULL;
    }
    errno_t ret = strncpy_s(dtbVrlFileName, nameSize, fileName, nameSize);
    if (ret != EOK) {
        SAFE_FREE(dtbVrlFileName);
        log_err("Str copy fail with %d\n", ret);
        return NULL;
    }
    size_t dtbExtLen = strlen(DTB_FILE_EXTENSION);
    ret = strncpy_s(dtbVrlFileName + (nameSize - dtbExtLen), dtbExtLen, "bin", dtbExtLen);
    if (ret != EOK) {
        SAFE_FREE(dtbVrlFileName);
        log_err("Str copy fail with %d\n", ret);
        return NULL;
    }
    return dtbVrlFileName;
}

/**
 * @brief       : add dtb file to chip_list
 * @param [in]  : dtbFileName      dtb file name
 * @return      : RC_SUCCESS: succeed; RC_ERROR: failed
 */
static int AddDtbFileToList(const char *dtbFileName)
{
    CHECK_NULL_PTR(dtbFileName, return RC_ERROR);
    struct stat st;
    if (stat(dtbFileName, &st) != 0) {
        log_err("Error: failed to get file state!\n");
        return RC_ERROR;
    }

    /* Extract the dtb file, decompile boardid parameter and
     * make chip struct to add to a list
     */
    if (!S_ISREG((signed short)st.st_mode) || (st.st_size == 0)) {
        log_err("Skip, it's not a regular file or failed to get DTB size\n");
        return RC_ERROR;
    }

    struct chipInfo_t *chip = getChipInfo(dtbFileName);
    if (chip == NULL) {
        log_err("Skip, failed to scan for '%s' tag\n", HSDT_DT_TAG);
        return RC_ERROR;
    }

    int ret = chip_add(chip);
    if (ret != RC_SUCCESS) {
        log_err("Error: duplicate boardid info!\n");
        return RC_ERROR;
    }

    /* Get dtb file name and
    *  Calculate dtb file size including page padding
    */
    chip->dt_entry.dtb_size = (uint32_t)((uint32_t)st.st_size +
        (page_size - ((uint32_t)st.st_size % page_size)));
    chip->dt_entry.dtb_file = (uint64_t)dtbFileName;
    chip->dt_entry.vrl_file = (uint64_t)GetDtbVrlFileName(dtbFileName, strlen(dtbFileName) + 1UL);
    if (chip->dt_entry.vrl_file == 0) {
        log_err("Get vrl file name fail\n");
        return RC_ERROR;
    }
    return RC_SUCCESS;
}

/**
 * @brief       : search all dtb files and add to chip_list
 * @param [in]  : srcDir        dir of dtb files
 * @param [out] : dtbCount      number of add successfully
 * @return      : RC_SUCCESS: succeed; RC_ERROR: failed
 */
static int AddAllDtbToList(const char *srcDir, uint32_t *dtbCount)
{
    CHECK_NULL_PTR(srcDir, return 0);
    int ret = RC_SUCCESS;
    DIR *dir = opendir(srcDir);
    if ((void *)dir == NULL) {
        log_err("Failed to open input directory '%s'\n", srcDir);
        return RC_ERROR;
    }

    while (1) {
        // read error or end of dir will return NULL
        struct dirent *dp = readdir(dir);
        if (dp == NULL) {
            break;
        }
        size_t fileLen = strlen(dp->d_name);
        size_t dtbExtLen = strlen(DTB_FILE_EXTENSION);
        if ((fileLen <= dtbExtLen) || (strncmp(&dp->d_name[fileLen - dtbExtLen], DTB_FILE_EXTENSION, dtbExtLen) != 0)) {
            continue;
        }
        char *fileName = GetFullFileName(srcDir, dp->d_name);
        if (fileName == NULL) {
            ret = RC_ERROR;
            log_err("Get full dtb file name fail\n");
            break;
        }

        log_info("==== %s\n", fileName);
        if (AddDtbFileToList(fileName) == RC_SUCCESS) {
            (*dtbCount)++;
        } else {
            log_err("Add dtb file:%s fail\n", fileName);
            SAFE_FREE(fileName);
            ret = RC_ERROR;
            break;
        }
    }
    SAFE_CLOSE_DIR(dir);
    return ret;
}

/**
 * @brief       : fill page when need
 * @param [in]  : fd         fd of dt.img
 * @param [out] : writeBytes number of write bytes
 * @param [in]  : padding    number of padding bytes
 * @return      : NA
 */
static void FillPage(int fd, ssize_t *writeBytes, size_t padding)
{
    size_t len = (size_t)page_size;
    if ((len == 0) || (len >= ULONG_MAX)) {
        log_err("Invalid size for malloc\n");
        return;
    }
    uint8_t *filler = (uint8_t *)malloc(len);
    if (filler == NULL) {
        log_err("Out of memory\n");
        return;
    }
    (void)memset_s(filler, len, 0, len);
    (*writeBytes) += write(fd, filler, padding);
    SAFE_FREE(filler);
}

/**
 * @brief       : write header and all dt_entry in chip_list
 * @param [in]  : fd         fd of dt.img
 * @param [in]  : dtbCount   number of dtb file
 * @param [out] : writeBytes number of write bytes
 * @param [out] : expected   expected bytes written
 * @return      : NA
 */
static void WriteDtTableAndEntry(int fd, uint32_t dtbCount, ssize_t *writeBytes, uint32_t *expected)
{
    uint32_t version = HSDT_VERSION;
    struct chipInfo_t *chip;
    /* Write header info */
    (*writeBytes) += write(fd, HSDT_MAGIC, sizeof(uint8_t) * 4UL); /* magic */
    (*writeBytes) += write(fd, &version, sizeof(uint32_t));      /* version */
    (*writeBytes) += write(fd, &dtbCount, sizeof(uint32_t));
    /* #DTB */

    /* Calculate offset of first DTB block */
    uint32_t dtb_offset = (sizeof(struct dt_table_t)) +    /* header */
        (sizeof(struct dt_entry_t) * dtbCount) + /* DTB table entries */
        4UL;                                      /* end of table indicator */
    /* Round up to page size */
    uint32_t padding = page_size - (dtb_offset % page_size);
    dtb_offset += padding;
    *expected = dtb_offset;
    /* Write index table:
        ____________________________________________________________________________
        |boardid|reserved|dtb_size|vrl_size|dtb_offset|vrl_offset|dtb_file|vrl_file|
     */
    for (chip = chip_list; chip != NULL; chip = chip->next) {
        if (chip->dt_entry.dtb_offset == 0) {
            chip->dt_entry.dtb_offset = *expected;
            (*expected) += chip->dt_entry.dtb_size;
        }
    }

    ssize_t vrl_offset = *expected;
    struct stat st;
    for (chip = chip_list; chip != NULL; chip = chip->next) {
        if ((stat((char *)chip->dt_entry.vrl_file, &st) == 0) && (st.st_size != 0)) {
            chip->dt_entry.vrl_offset = (uint32_t)vrl_offset;
            ssize_t vrl_size = st.st_size + (ssize_t)(page_size - ((uint32_t)st.st_size % page_size));
            vrl_offset += vrl_size;
            chip->dt_entry.vrl_size = (uint32_t)vrl_size;
        } else {
            chip->dt_entry.vrl_offset = 0;
            chip->dt_entry.vrl_size = 0;
        }
    }

    for (chip = chip_list; chip != NULL; chip = chip->next) {
        uint64_t dtb_file, vrl_file;
        dtb_file = chip->dt_entry.dtb_file;
        vrl_file = chip->dt_entry.vrl_file;
        chip->dt_entry.dtb_file = 0;
        chip->dt_entry.vrl_file = 0;
        (*writeBytes) += write(fd, &chip->dt_entry, sizeof(struct dt_entry_t));
        chip->dt_entry.dtb_file = dtb_file;
        chip->dt_entry.vrl_file = vrl_file;
    }

    int rc = RC_SUCCESS;
    (*writeBytes) += write(fd, &rc, sizeof(uint32_t)); /* end of table indicator */
    if (padding > 0) {
        FillPage(fd, writeBytes, (size_t)padding);
    }
}

/**
 * @brief       : read from src and write to dest
 * @param [in]  : destfd     fd of dt.img
 * @param [in]  : srcFp      src file
 * @param [out] : writeBytes number of write bytes
 * @return      : total read bytes: succeed; 0: failed
 */
static uint32_t WriteFile(int destFd, FILE *srcFp, ssize_t *writeBytes)
{
    char buf[COPY_BLK] = {0};
    uint32_t totBytesRead = 0;
    uint32_t numBytesRead = 0;
    if (destFd < 0 || srcFp == NULL) {
        log_err("Invalid write param\n");
        return 0;
    }

    while (1) {
        numBytesRead = (uint32_t)fread(buf, 1, COPY_BLK, srcFp);
        if (numBytesRead == 0) {
            break;
        }
        (*writeBytes) += write(destFd, buf, numBytesRead);
        totBytesRead += numBytesRead;
    }
    return totBytesRead;
}

/**
 * @brief       : write all dtb files into dt.img
 * @param [in]  : fd         fd of dt.img
 * @param [out] : writeBytes number of write bytes
 * @return      : RC_SUCCESS: succeed; RC_ERROR: failed
 */
static int WriteDTBFiles(int fd, ssize_t *writeBytes)
{
    uint32_t dtbSize = 0;
    uint32_t totBytesRead = 0;
    uint32_t padding = 0;
    struct chipInfo_t *chip;
    if (fd < 0) {
        log_err("Invalid write fd\n");
        return RC_ERROR;
    }
    for (chip = chip_list; chip != NULL; chip = chip->next) {
        char *fileName = (char *)(chip->dt_entry.dtb_file);
        FILE *pInputFile = fopen(fileName, "r");
        if (pInputFile == NULL) {
            log_err("Failed to open DTB '%s'\n", fileName);
            return RC_ERROR;
        }
        dtbSize = chip->dt_entry.dtb_size;
        totBytesRead = WriteFile(fd, pInputFile, writeBytes);
        SAFE_FCLOSE(pInputFile);
        padding = page_size - (totBytesRead % page_size);

        if ((totBytesRead + padding) != dtbSize) {
            log_err("DTB size mismatch, please re-run: expected %u vs actual %u (%s)\n", dtbSize,
                totBytesRead + padding, fileName);
            return RC_ERROR;
        }
        if (padding > 0) {
            FillPage(fd, writeBytes, (size_t)padding);
        }
    }
    return RC_SUCCESS;
}

/**
 * @brief       : write all dtb vrl files into dt.img
 * @param [in]  : fd         fd of dt.img
 * @param [out] : writeBytes number of write bytes
 * @return      : NA
 */
static void WriteDTBVRLFiles(int fd, ssize_t *writeBytes)
{
    uint32_t totBytesRead = 0;
    uint32_t padding = 0;
    struct chipInfo_t *chip;
    for (chip = chip_list; chip != NULL; chip = chip->next) {
        char *fileName = (char *)(chip->dt_entry.vrl_file);
        FILE *pInputFile = fopen(fileName, "r");
        if (pInputFile == NULL) {
            log_err("Failed to open VRL '%s'\n", fileName);
            break;
        }
        totBytesRead = WriteFile(fd, pInputFile, writeBytes);
        SAFE_FCLOSE(pInputFile);
        padding = page_size - (totBytesRead % page_size);

        if (padding > 0) {
            log_err("Padding is [%u] \n", padding);
            FillPage(fd, writeBytes, (size_t)padding);
        } else {
            log_err("File size is 0! '%s'\n", fileName);
        }
    }
}

/**
 * @brief       : write dt.img
 * @param [in]  : fd         fd of dt.img
 * @param [in]  : dtbCount   number of dtb file
 * @return      : RC_SUCCESS: succeed; RC_ERROR: failed
 */
static int WriteDtImg(int fd, uint32_t dtbCount)
{
    ssize_t writeBytes = 0;
    uint32_t expected = 0;
    WriteDtTableAndEntry(fd, dtbCount, &writeBytes, &expected);
    /* Write DTB's */
    int rc = WriteDTBFiles(fd, &writeBytes);
    if (expected != (uint32_t)writeBytes) {
        log_err("[Write DTB]error writing output file, please rerun: size mismatch %u vs %zd\n", expected, writeBytes);
        rc = RC_ERROR;
    } else {
        log_dbg("Total wrote %zd bytes\n", writeBytes);
    }
    /* Write VRL's */
    WriteDTBVRLFiles(fd, &writeBytes);
    return rc;
}

int main(int argc, char **argv)
{
    uint32_t dtb_count = 0;

    log_info("DTB combiner:\n");

    if (parse_commandline(argc, argv) != RC_SUCCESS) {
        print_help();
        return RC_ERROR;
    }

    log_info("  Input directory: '%s'\n", input_dir);
    log_info("  Output file: '%s'\n", output_file);
    log_info("\nGenerating master DTB... \n");

    /* Open the .dtb files in the specified path, decompile and
     * extract "hisi,boardid" parameter
     */
    int rc = AddAllDtbToList(input_dir, &dtb_count);
    if (rc == RC_ERROR || dtb_count == 0){
        log_err("add dtb file to list fail, file num:%u\n", dtb_count);
        chip_deleteall();
        return RC_ERROR;
    }
    log_info("=> Found %u unique DTB(s)\n", dtb_count);

    /* Generate the master DTB file:
     * Simplify write error handling by just checking for actual vs
     * expected bytes written at the end.
     */
    log_info("\nGenerating master DTB... \n");
    int out_fd = open(output_file, (O_WRONLY | O_CREAT), (S_IRUSR | S_IWUSR));
    if (out_fd < 0) {
        log_err("Cannot create '%s'\n", output_file);
        chip_deleteall();
        return RC_ERROR;
    }

    rc = WriteDtImg(out_fd, dtb_count);
    SAFE_CLOSE(out_fd);
    if (rc != RC_SUCCESS) {
        (void)unlink(output_file);
    } else {
        log_info("completed\n");
    }

    chip_deleteall();
    return rc;
}
