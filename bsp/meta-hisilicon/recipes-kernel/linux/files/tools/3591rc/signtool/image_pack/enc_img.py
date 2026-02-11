#!/usr/bin/env python
#-*- coding: utf-8 -*-
#----------------------------------------------------------------------------
# Purpose:
# Copyright Technologies Co., Ltd. 2010-2025. All rights reserved.
#----------------------------------------------------------------------------
import struct
import sys
import hashlib
import argparse
import textwrap
from tools import *
import binascii
from ctypes import *
import os
import shutil

# image encrypt operation:
def __img_key_and_nonce_gen(key_path, key_len):
    from Crypto import Random
    with open(key_path, 'rb') as f:
        key = f.read()
    from Crypto.Protocol.KDF import PBKDF2
    from Crypto.Hash import SHA256, HMAC
    salt = Random.get_random_bytes(32)
    key_rvs = key[::-1]
    if key_len == 32:  #pbkdf2-sha256
        print(binascii.hexlify(key_rvs))
        key_der = PBKDF2(key_rvs, salt, key_len, 1000, prf=lambda p,s: HMAC.new(p, s, SHA256).digest())
        nonce = Random.get_random_bytes(12)
        return key_der, salt, nonce
    elif key_len == 16: #pbkdf2-sm3
        key_rvs = key_rvs[:key_len]
        print(binascii.hexlify(key_rvs))
        import hi_platform.gm.sm3 as sm3
        sm3_key = [0] * len(key_rvs)
        sm3.sm3_pbkdf2(salt, len(salt), key_rvs, len(key_rvs), 1000, sm3_key)
        print("sm3_key = ", end='')
        for i in range(0, len(sm3_key)):
            print("{0:x}, ".format(sm3_key[i]), end = '')
        print("\nlen = {0}".format(len(sm3_key)))
        raw_key = b''
        for i in range(0, len(sm3_key)):
            raw_key += struct.pack('B', sm3_key[i])
        iv = Random.get_random_bytes(16)
        return raw_key, salt, iv

def __header_write_salt_and_iv(out, salt, nonce="", counter=0, iv="", head_type=0):
    offset = 0x146C if head_type else 0x46C
    out.seek(offset)
    if nonce != "":
        out.write(nonce)
        counter_bin = counter.to_bytes(4, 'big') if sys.version > '3' else to_bytes(counter, 4)
        out.write(counter_bin)
    elif iv != "":
        out.write(iv)
    out.write(salt)
    offset = 0x1464 if head_type else 0x464
    out.seek(offset)
    enc_flag = struct.pack("I", 0x5AA55AA5)
    out.write(enc_flag)

def __aes_encrypt_and_write_raw_img(out, key, nonce, counter, raw, suffix=False):
    offset = 0 if suffix else 0x2000
    out.seek(offset)
    with open(raw, 'rb') as raw_file:
        raw_file.seek(offset)
        from Crypto.Cipher import AES
        cipher = AES.new(key, AES.MODE_CTR, nonce=nonce, initial_value=counter)
        for byte_block in iter(lambda: raw_file.read(4096), b""):
            byte_block_ct = cipher.encrypt(byte_block)
            out.write(byte_block_ct)

def __sm4_encrypt_and_write_raw_img(out, key, iv, raw, suffix=False):
    offset = 0 if suffix else 0x2000
    out.seek(offset)
    print("sm4_key:")
    print(key.hex())

    with open(raw, 'rb') as raw_file:
        raw_file.seek(offset)
        pt = raw_file.read()
        import hi_platform.gm.sm4 as test_sm4
        
        test_ct = test_sm4.sm4_cbc_op(pt, iv, key)
        out.write(test_ct)

def __write_header_hash(out, suffix=False, head_type=0):
    header_base = 0x1000 if head_type else 0
    offset = (0xC000 + header_base) if suffix else header_base
    out.seek(offset)
    header = out.read(0x4BC)
    out.write(cal_bin_hash(header))

def enc_image(args, out):
    if args.enc == "aes":
        key_der, salt, nonce = __img_key_and_nonce_gen(args.key, 32)
        for i in range(32):
            print("0x%x, " % key_der[i], end='')

        counter = 0x1
        __header_write_salt_and_iv(out, salt, nonce=nonce, counter=counter, head_type=0)
        if args.B:
            print("BCM mode")
        else:
            __header_write_salt_and_iv(out, salt, nonce=nonce, counter=counter, head_type=1)
        __aes_encrypt_and_write_raw_img(out, key_der, nonce, counter, args.raw, args.S)
    elif args.enc == "sm4":
        key_der, salt, iv = __img_key_and_nonce_gen(args.key, 16)
        for i in range(16):
            print("0x%x, " % key_der[i], end='')
        print('\n')
        __header_write_salt_and_iv(out, salt, iv=iv, head_type=0)
        if args.B:
            print("BCM mode")
        else:
            __header_write_salt_and_iv(out, salt, iv=iv, head_type=1)
        __sm4_encrypt_and_write_raw_img(out, key_der, iv, args.raw, args.S)
    else:
        raise ValueError("error enc type {0}".format(args.enc))
    __write_header_hash(out, args.S)

    if args.B:
        print("BCM MODE")
    else:
        __write_header_hash(out, args.S, 1)

def get_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
                                     description=textwrap.dedent('''
                                     A tool to encrypt image'''))
    parser.add_argument('-raw_img', required=True, dest='raw', help='INPUT: The raw image')
    parser.add_argument('-out_img', required=True, dest='out',
                        help='OUTPUT: The processed image. Filename can be same to input image')
    parser.add_argument('-platform', required=True, dest='platform', choices=['ascend610', 'hi1910p', 'as31xm1'],
                        help='INPUT: platform : ascend610,hi1910p,as31xm1')

    parser.add_argument('-S', help="choose whether Onchiprom", action="store_true")
    parser.add_argument('-B', help="choose whether bcm", action="store_true")

    # encrypt related
    parser.add_argument('-enc', choices=['aes', 'sm4'], help="enc mode")
    parser.add_argument('-key', required=True, dest='key', help='INPUT: The encrypt key')

    return parser.parse_args()

def main():
    tmp_file = args.out + '.tmp'
    with open(args.raw, "rb") as f:
        with open(tmp_file, 'wb+') as o_f:
            head = f.read(0x2000)
            o_f.write(head)
            enc_image(args, o_f)

    shutil.copyfile(tmp_file, args.out)
    if os.path.exists(tmp_file):
        os.remove(tmp_file)

if __name__ == '__main__':
    args = get_args()
    if args.platform not in ['ascend610', 'hi1910p', 'as31xm1']:
        raise ValueError("error platform type {0}".format(args.platform))
    main()
