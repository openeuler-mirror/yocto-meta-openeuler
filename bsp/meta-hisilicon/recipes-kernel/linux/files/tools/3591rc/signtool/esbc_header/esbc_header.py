#!/usr/bin/env python
#-*- coding: utf-8 -*-
#----------------------------------------------------------------------------
# Purpose:
# Copyright Technologies Co., Ltd. 2010-2025. All rights reserved.
#----------------------------------------------------------------------------
import xml.etree.ElementTree as ET
import argparse
import textwrap
import struct
import shutil
import os
from tools import *
import hashlib
import binascii

def trans_hw_logic_version(version):
    """Transform hw_logic_version to hex string.

    >>> trans_hw_logic_version('')
    'ffffffff'
    >>> trans_hw_logic_version('0')
    'a5000000'
    >>> trans_hw_logic_version('235')
    'a500eb00'
    >>> trans_hw_logic_version('300')
    'a5002c01'
    """
    if not version:
        return 'ffffffff'
    magic_num = 0xa5
    magic_num_hex = magic_num.to_bytes(1, byteorder='little').hex()
    reserved = 0
    reserved_hex = reserved.to_bytes(1, byteorder='little').hex()
    version = int(version)
    version_hex = version.to_bytes(2, byteorder='little').hex()
    return magic_num_hex + reserved_hex + version_hex

def get_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
                                     description=textwrap.dedent('''
                                     A tool to pack image with new structure'''))
    parser.add_argument('-raw_img', required=True, dest='raw', help='INPUT: The raw image')
    parser.add_argument('-out_img', required=True, dest='out', help='OUTPUT: The processed image.')
    parser.add_argument('-version', required=True, dest='ver', help='INPUT: The version number')
    parser.add_argument('-nvcnt', required=True, dest='nvcnt', choices=range(32), type=int,
                        help='INPUT: the secure version number')
    parser.add_argument('-tag', required=True, dest='tag', help='INPUT: image name tag')
    parser.add_argument('-platform', required=True, dest='platform', help='INPUT: platform info')
    parser.add_argument('-position',  choices=['before_header', 'after_header'], help='INPUT: The relative position of raw_img and head')
    parser.add_argument('-hw_logic_version', default='', type=trans_hw_logic_version, help='INPUT: hw logic version')
    return parser.parse_args()

if __name__ == '__main__':
    args = get_args()
    if args.platform == 'ascend610' or args.platform == 'hi1910p' or args.platform == 'hi1910prc' or args.platform == 'bs9sx1a' or args.platform == 'ascend610lite':
        s = struct.Struct('I16sI4I2I208s') if (args.position == 'before_header') else struct.Struct('I16sI4I2I64s')
        ver_value = list(map(int, args.ver.split('.'), [16] * 5))
        ver_value[3] = (ver_value[3] << 16) | (ver_value[4] & 0xFFFF)
        magic_num = 0x3a3aaa33
        code_tag = bytes(args.tag,'ascii')
        nvcnt_code = args.nvcnt
        sign_enable_field = 0x4
        hashtree_offset = 0x20000  #128K
        para = int(0).to_bytes(208, 'big') if (args.position == 'before_header') else int(0).to_bytes(64, 'big')
        fs_offset = 0 if (args.position == 'before_header') else 0x100

        with open(args.raw, 'rb') as f:
            code_len = get_filelen(f)
            esbc_offset = code_len if (args.position == 'before_header') else 0
            tmp_file = args.out + '.tmp'
            f.seek(0)
            with open(tmp_file, 'wb') as o_f:
                o_f.seek(fs_offset)
                for byte_block in iter(lambda: f.read(4096), b""):
                    o_f.write(byte_block)
                pack_list = (magic_num, code_tag, nvcnt_code,
                            ver_value[0], ver_value[1], ver_value[2], ver_value[3],
                            sign_enable_field, hashtree_offset, para)
                header = s.pack(*pack_list)
                o_f.seek(esbc_offset)
                o_f.write(header)
        shutil.copyfile(tmp_file, args.out)
        if os.path.exists(tmp_file):
            os.remove(tmp_file)
    elif args.platform == 'hi1111A' or args.platform == 'hi1910B' or args.platform == 'hi1910Brc' or args.platform == 'ascend' or \
         args.platform == 'as31xm1' or args.platform == 'hn920' or args.platform == 'hi1980D':
        s = struct.Struct('16sII64sII8s4I3I124s')
        code_tag = bytes(args.tag,'ascii')
        nvcnt_code = args.nvcnt
        hash_alg = 0
        hash_ex = hashlib.sha256()
        code_offset = 0 if (args.position == 'before_header') else 0x100
        reserved1 = int(0).to_bytes(8, 'big')
        ver_value = list(map(int, args.ver.split('.'), [16] * 5))
        ver_value[3] = (ver_value[3] << 16) | (ver_value[4] & 0xFFFF)
        magic_num = 0x3a3aaa33
        sign_enable_field = 0x4
        hashtree_offset = 0x20000  #128K
        padding = args.hw_logic_version + "ff" * 120 # fixed padding at the end of imgdesc
        reserved2 = binascii.a2b_hex(padding)
        fs_offset = 0 if (args.position == 'before_header') else 0x100
        with open(args.raw, 'rb') as f:
            code_len = get_filelen(f)
            esbc_offset = code_len if (args.position == 'before_header') else 0
            tmp_file = args.out + '.tmp'
            f.seek(0)
            with open(tmp_file, 'wb') as o_f:
                o_f.seek(fs_offset)
                code = b''
                for byte_block in iter(lambda: f.read(4096), b""):
                    o_f.write(byte_block)
                    hash_ex.update(byte_block)
                code_hash = hash_ex.digest()
                pack_list = (code_tag, nvcnt_code, hash_alg, code_hash, code_offset, code_len, reserved1,
                ver_value[0], ver_value[1], ver_value[2], ver_value[3], magic_num, sign_enable_field, hashtree_offset, reserved2)
                header = s.pack(*pack_list)
                o_f.seek(esbc_offset)
                o_f.write(header)
            shutil.copyfile(tmp_file, args.out)
            if os.path.exists(tmp_file):
                os.remove(tmp_file)
