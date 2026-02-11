#!/usr/bin/python
#-*- coding: UTF-8 -*-
#----------------------------------------------------------------------------
# Purpose:
# Copyright Technologies Co., Ltd. 2010-2018. All rights reserved.
# Author: shuaihua
#----------------------------------------------------------------------------

import struct
import argparse
import textwrap


def get_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
                                     description=textwrap.dedent('''
                                     A tool to pack image with new structure'''))
    parser.add_argument('-raw_img', required=True, dest='raw',
                        help='INPUT/OUTPUT: The raw image path')
    parser.add_argument('-platform', required=True, dest='platform',
                        help='INPUT: 1: 1910 2: 1980, else false')
    parser.add_argument('-firmware', required=True, dest='firmware',
                        help='INPUT: 1: xloader 2: uefi, else false')
    return parser.parse_args()


def __construct_tail_st(pf_type, fw_type):
    s = struct.Struct('III13I')
    magic = 0x7324BC8A
    if pf_type in (1, 2):
        pf_flag = pf_type
    else:
        raise
    if fw_type in (1, 2):
        fw_flag = 0x00000010 + fw_type - 1

    arr = [magic, pf_flag, fw_flag]
    arr.extend([0] * 13)
    return s.pack(*tuple(arr))


def main():
    args = get_args()
    with open(args.raw, "rb+") as f:
        f.seek(0, 2)
        length = f.tell()
        aligned = ((length + 15) // 16) * 16
        f.seek(aligned)
        f.write(__construct_tail_st(int(args.platform), int(args.firmware)))


if __name__ == '__main__':
    main()
