#!/usr/bin/env python
#-*- coding: utf-8 -*-
#----------------------------------------------------------------------------
# Purpose:
# Copyright Technologies Co., Ltd. 2010-2025. All rights reserved.
#----------------------------------------------------------------------------
import argparse
import textwrap
import binascii
import sys
import os
import shutil
import struct


def __write_raw_img(out, raw):
    offset = 0x0
    out.seek(offset)
    with open(raw, 'rb') as raw_file:
        for byte_block in iter(lambda: raw_file.read(4096), b""):
            out.write(byte_block)

def write_image(raw, out):
    __write_raw_img(out, raw)

def get_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
                                     description=textwrap.dedent('''
                                     A tool to pack image with new structure'''))
    parser.add_argument('-raw_img', required=True, dest='raw', help='INPUT: The raw image')
    parser.add_argument('-out_img', required=True, dest='out', help='OUTPUT: The output image')
    parser.add_argument('-nvcnt', required=True,  help='INPUT: The raw image')
    parser.add_argument('-FORCE_CNT', required=False,  help='specific nvcnt')
    parser.add_argument('-platform', required=True, dest='platform', help='INPUT: platform info')
    return parser.parse_args()

def main():
    new_drv_flag = False
    if args.raw.find("Image") >= 0 or args.raw.find("filesystem") >= 0:
       new_drv_flag = True
    if args.platform == 'hi1980':
        tmp_file = args.out + '.tmp'
        with open(tmp_file, 'wb+') as o_f:
            write_image(args.raw, o_f)
            if new_drv_flag == True:
                s = struct.Struct('III')
            else:
                s = struct.Struct('II')
            new_drv_magic = 0x464C5144 # verion magic number for old-driver
            nvCntMagic = 0x5a5aa5a5 # nvcnt magic number
            nvCntDevelop = 0x1 # default nvcnt
            if not args.FORCE_CNT is None:
                nvCntDevelop = int(args.FORCE_CNT)
            print("NVCNT>>>>>"+str(nvCntDevelop))
            if new_drv_flag == True:
                pack_list = (new_drv_magic, nvCntMagic, nvCntDevelop)
            else:
                pack_list = (nvCntMagic, nvCntDevelop)
            nvCntTail = s.pack(*pack_list)
            o_f.write(nvCntTail)
            o_f.close()
        shutil.copyfile(tmp_file, args.out)
        if os.path.exists(tmp_file):
            os.remove(tmp_file)
    else:
        print('Unsupport chip:'+args.platform)

if __name__ == '__main__':
    args = get_args()
    main()
