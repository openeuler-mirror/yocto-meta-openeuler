#!/usr/bin/env python
#-*- coding: utf-8 -*-
#----------------------------------------------------------------------------
# Purpose:
# Copyright Technologies Co., Ltd. 2010-2025. All rights reserved.
#----------------------------------------------------------------------------
import hashlib

def cal_bin_hash(buf):
    sha256_hash = hashlib.sha256()
    sha256_hash.update(buf)
    return sha256_hash.digest()


def cal_image_hash(f):
    sha256_hash = hashlib.sha256()
    for byte_block in iter(lambda: f.read(4096), b""):
        sha256_hash.update(byte_block)
    f.seek(0)
    return sha256_hash.digest()


def to_bytes(n, length, endianess='big'):
    h = '%x' % n
    s = ('0' * (len(h) % 2) + h).zfill(length * 2).decode('hex')
    return s if endianess == 'big' else s[::-1]


def get_filelen(f):
    f.seek(0, 2)
    length = f.tell()
    f.seek(0)
    return length
