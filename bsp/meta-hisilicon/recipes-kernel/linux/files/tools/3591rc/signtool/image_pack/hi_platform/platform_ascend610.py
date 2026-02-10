#!/usr/bin/env python
#-*- coding: utf-8 -*-
#----------------------------------------------------------------------------
# Purpose:
# Copyright Technologies Co., Ltd. 2010-2025. All rights reserved.
#----------------------------------------------------------------------------
import struct
import sys
import hashlib
from tools import *
import binascii
from ctypes import *
import os

# typedef struct secboot_image_head_st
# {
#     uint32_t preamble;/*0x55aa55aa*/
#     uint32_t head_len; /*don't check in secure boot*/
#     uint32_t user_len; /*don't check in secure boot*/
#     uint8_t  user_define_data[32]; /*don't check in secure boot*/
#     uint8_t  code_hash[HASH_SIZE]; /*image hash value, don't check in secure boot*/
#     uint32_t sub_key_cert_offset;
#     uint32_t code_sign_algo; /*[15:0]Hash algorithm;0x0-SHA256,others: reserved
#                           [31:22](10bit)signature parasms.RSA_PKCS1-0,RSA_PSS standsfor salt length(byte)
#                           [21:16](6bit)signature algorithm.0x0:RSA_PKCS1; 0x1: RSA_PSS*/
#     uint32_t root_pubkey_len; /*rootpukkey length,512 bytes*/
#     uint8_t  root_pubkey[RSA_ROOTKEY_WIDTH_BYTES]; /*N value, length is RootPubKLen*/
#     uint8_t  root_pubkey_e[RSA_ROOTKEY_WIDTH_BYTES]; /*E valuse and fixed to 65537*/
#     uint32_t code_offset; /*addr offset between code_image*/
#     uint32_t code_len;
#     uint32_t sign_offset;
#     uint32_t code_encrypt_flag;
#     uint32_t code_encrypt_algo;
#     uint8_t  code_encrypt_iv[SCB_ENCRPT_IV_LEN];
#     uint8_t  code_derive_seed[SCB_DERIVE_SEED_LEN];
#     uint8_t  code_encrypt_tag[16];  /*16 bytes reserved*/
#     uint32_t head_magic; /*0x33cc33cc*/
#     uint8_t  head_hash[HASH_SIZE];
# } SE_IMAGE_HEAD;

def __write_code_offset(code_len, suffix, head_type, before_header):
    header_base = 0x1000 if head_type else 0

    if before_header:
        code_offset = 0
    else:
        # offset 0xC000 for onchiprom, 0x4000 for normal img
        code_offset = (0xC000 + header_base) if suffix else (0x2000 - header_base)
        if suffix and code_len > 0xC000:
            raise MemoryError('Codelen too long for onchiprom')
    return code_offset

def __construct_header(N_buf, E_buf, hash_buf, code_len, suffix,
                       head_type, before_header=False, large_packet=False, enc=False, pss=False, bcm=False):
    zero_bytes_32 = int(0).to_bytes(32, 'big') if sys.version > '3' else to_bytes(0, 32)

    s = struct.Struct('III32s32sIII512s512sIIIII16s32s16sIIII')
    preamble = 0x55AA55AA
    head_len = 0x4DC
    user_len = 0xFFFFFFFF
    user_define_data = zero_bytes_32
    code_hash = hash_buf
    sub_key_cert_offset = 0x500
    code_sign_algo = 0x8010000 if pss else 0
    root_pubkey_len = 512
    root_pubkey = N_buf
    root_pubkey_e = E_buf
    code_offset = __write_code_offset(code_len, suffix, head_type, before_header)
    #code_len
    sign_offset = 0xE00
    code_encrypt_flag = 0x5AA55AA5 if enc else 0xFFFFFFFF
    code_encrypt_algo = 0
    code_encrypt_iv = zero_bytes_32
    code_derive_seed = zero_bytes_32
    code_encrypt_tag = zero_bytes_32[:16]

    if bcm:
        h2c_enable = 0x41544941
        h2c_cert_len = 0x624
        h2c_cert_offset = 0x1000
    else:
        h2c_enable = 0xA5A55555
        h2c_cert_offset = 0
        h2c_cert_len = 0

    # if rootfs/app.img is large_packet(>4G), stub code_len 0 (invalid value)
    code_len = 0 if before_header and large_packet else code_len

    head_magic = 0x33CC33CC
    pack_list = (preamble, head_len, user_len, user_define_data, code_hash, sub_key_cert_offset,
                 code_sign_algo, root_pubkey_len, root_pubkey, root_pubkey_e, code_offset,
                 code_len, sign_offset, code_encrypt_flag, code_encrypt_algo, code_encrypt_iv,
                 code_derive_seed, code_encrypt_tag, h2c_enable, h2c_cert_len, h2c_cert_offset, head_magic)
    header = s.pack(*pack_list)
    # print(binascii.hexlify(header))
    return header

def __get_filelen(f):
    f.seek(0, 2)
    length = f.tell()
    f.seek(0)
    return length

def __write_header(args, out, header, suffix=False, head_type=0, code_len=0, before_header=False):
    header_base = 0x1000 if head_type else 0
    header_base = (header_base + code_len) if before_header else header_base
    offset = (0xC000 + header_base) if suffix else header_base
    out.seek(offset)
    out.write(header)
    # Write additional nvcnt to head
    # nvcnt_offset : 0xB18
    # [
    #     U32 nvcnt_magic : 0x5A5AA5A5
    #     U32 nvcnt
    # ] nvcnt_s
    if args.nvcnt:
        s = struct.Struct('II')
        nvcnt_magic = 0x5A5AA5A5
        pack_list = (nvcnt_magic, int(args.nvcnt))
        nvcnt_s = s.pack(*pack_list)
        nvcnt_offset = (offset + 0xB18)
        out.seek(nvcnt_offset)
        out.write(nvcnt_s)

def __write_header_hash(out, suffix=False, head_type=0, code_len=0):
    header_base = 0x1000 if head_type else 0
    offset = (0xC000 + header_base) if suffix else header_base + code_len
    out.seek(offset)
    header = out.read(0x4BC)
    out.write(cal_bin_hash(header))


def __write_cert(out, cert, suffix=False, head_type=0):
    header_base = 0x1000 if head_type else 0
    offset = (0xC000 + header_base + 0x500) if suffix else (header_base + 0x500)
    with open(cert, 'rb') as c_f:
        cert_buf = c_f.read()
        out.seek(offset)
        out.write(cert_buf)


def __write_signature(out, sig, suffix=False, head_type=0):
    header_base = 0x1000 if head_type else 0
    offset = (0xC000 + header_base + 0xE00) if suffix else (header_base + 0xE00)
    with open(sig, 'rb') as s_f:
        sig_buf = s_f.read()
        out.seek(offset)
        out.write(sig_buf)

# image encrypt operation:
def __img_key_and_nonce_gen(key_path, key_len):
    from Crypto import Random
    with open(key_path, 'rb') as f:
        key = f.read()
        # key = int(0).to_bytes(32, "big")
    from Crypto.Protocol.KDF import PBKDF2
    from Crypto.Hash import SHA256, HMAC
    salt = Random.get_random_bytes(32)
    # salt = int(0).to_bytes(32, "big")
    key_rvs = key[::-1]
    # key_rvs = key
    if key_len == 32:  #pbkdf2-sha256
        print(binascii.hexlify(key_rvs))
        key_der = PBKDF2(key_rvs, salt, key_len, 1000, prf=lambda p,s: HMAC.new(p, s, SHA256).digest())
        nonce = Random.get_random_bytes(12)
        return key_der, salt, nonce
    elif key_len == 16: #pbkdf2-sm3
        '''
        _file = 'gmssl/libalgorithm.so'
        _path = os.path.join(*(os.path.split(os.path.abspath(__file__))[:-1] + (_file,)))
        crypto_lib = cdll.LoadLibrary(_path)
        '''
        key_rvs = key_rvs[:key_len]
        print(binascii.hexlify(key_rvs))
        '''
        c_sm3_root_key = (c_char * len(key_rvs))(*key_rvs)
        c_salt = (c_char * len(salt))(*salt)
        key_der = create_string_buffer(len(key_rvs))

        # unsigned char *sm3_pbkdf2(const unsigned char *salt, size_t salt_len,
        # const unsigned char *data, size_t data_len, size_t cnt, unsigned char *h);

        crypto_lib.sm3_pbkdf2(c_salt, len(salt), c_sm3_root_key, len(key_rvs), 1000, key_der)

        print("key_der = {0}, type = {1}".format(key_der.raw, type(key_der.raw)))
        '''
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
        #return key_der.raw, salt, iv
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


def __write_raw_img(out, raw, suffix=False, before_header=False):
    offset = 0 if suffix or before_header else 0x2000
    out.seek(offset)
    with open(raw, 'rb') as raw_file:
        for byte_block in iter(lambda: raw_file.read(4096), b""):
            out.write(byte_block)


def __aes_encrypt_and_write_raw_img(out, key, nonce, counter, raw, suffix=False):
    offset = 0 if suffix else 0x2000
    out.seek(offset)
    with open(raw, 'rb') as raw_file:
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
        '''
        from gmssl.sm4 import CryptSM4, SM4_ENCRYPT
        crypt_sm4 = CryptSM4()
        crypt_sm4.set_key(key, SM4_ENCRYPT)
        '''
        pt = raw_file.read()
        
        import hi_platform.gm.sm4 as test_sm4
        
        test_ct = test_sm4.sm4_cbc_op(pt, iv, key)
        
        out.write(test_ct)

def __add_in_tail(offset, inFile, outFile, header, length):
    outFile.seek(offset, 1)
    outFile.write(header)
    outFile.write(inFile.read())
    outFile.seek(-(length + 16), 1)


def __construct_cms_header(tag, length):
    s = struct.Struct('12sI')
    if (len(tag) > 11):
        raise RuntimeError('name too long')
    value = (tag.encode(), length)
    header = s.pack(*value)
    # print(binascii.hexlify(header))
    return header


def __write_cms(out, cms, aligned_bytes):
    with open(cms, 'rb') as cf:
        length = __get_filelen(cf)
        header = __construct_cms_header('cms', length)
        __add_in_tail(aligned_bytes, cf, out, header, length)


def __write_ini(out, ini, pss=False):
    with open(ini, 'rb') as ifile:
        length = __get_filelen(ifile)
        header = __construct_cms_header('ini', length)
        cms_size = 0x4000 if pss else 0x2000
        __add_in_tail(cms_size, ifile, out, header, length)


def __write_crl(out, crl):
    with open(crl, 'rb') as af:
        length = __get_filelen(af)
        header = __construct_cms_header('crl', length)
        __add_in_tail(2 * 1024, af, out, header, length)


def __construct_version(ver):
    s = struct.Struct("4I")
    value = tuple(map(int, ver.split('.'), [16] * 4))
    return s.pack(*value)


def __write_version(out, ver, suffix=False):
    version = __construct_version(ver)
    # print(binascii.hexlify(version))
    offset = 0xC480 if suffix else 0x480
    out.seek(offset)
    out.write(version)


def __add_magic_number_and_file_size(out, cms_flag, before_header, large_packet, code_len=0, suffix=False):
    if cms_flag and suffix:
        raise RuntimeError("Invalid Param: --addcms and -S can't input in the same time.")

    out.seek(0, 2)
    # if before_header img code_len >= 4G, img_len = 0 (not used)
    fileSize = 0 if before_header and (out.tell() >= 0x100000000) else out.tell()
    s = struct.Struct('QIQ')
    # only rawdata img use cms_tag(0xABCD1234AA55AA55) and fileSize, code_len(u long long) used in rootfs/app.img
    if cms_flag:
        value = (0xABCD1234AA55AA55, fileSize, code_len)
    else:
        value = (0x0, fileSize, code_len)
    stream = s.pack(*value)
    # print(binascii.hexlify(stream))
    offset = 0x4E0 + code_len
    out.seek(offset, 0)
    out.write(stream)

# platform_api as follow
def __write_single_header(args, out, hash_buf, code_len, head_type=0):
    if args.addsoc:
        from Crypto.PublicKey import RSA
        with open(args.root, 'rb') as r_f:
            if args.root:
                if args.root_raw:
                    N_data = int(r_f.readline().strip(), 16)
                    E_data = int(r_f.readline().strip(), 16)
                    D_data = int(r_f.readline().strip(), 16)
                    pk = RSA.construct(N_data, E_data, D_data)
                else:
                    pk = RSA.importKey(r_f.read())

            if sys.version > '3':
                N_buf, E_buf = pk.n.to_bytes(512, 'big'), pk.e.to_bytes(512, 'big')
            else:
                N_buf, E_buf = to_bytes(pk.n, 512), to_bytes(pk.e, 512)

        __write_cert(out, args.cert, args.S, head_type)
        __write_signature(out, args.sig, args.S, head_type)

    else:
        if sys.version > '3':
            N_buf, E_buf = int(0).to_bytes(512, 'big'), int(0).to_bytes(512, 'big')
        else:
            N_buf, E_buf = to_bytes(0, 512), to_bytes(0, 512)

    before_header = True if (args.position == 'before_header') else False
    large_packet = True if (args.pkt_type == 'large_pkt') else False
    header = __construct_header(N_buf, E_buf, hash_buf, code_len, args.S, head_type,
                                before_header, large_packet, args.enc, pss=args.pss, bcm=args.B)
    __write_header(args, out, header, args.S, head_type, code_len, before_header)


def write_header_huawei(args, out, hash_buf, code_len):
    __write_single_header(args, out, hash_buf, code_len)


def write_header_customer(args, out, hash_buf, code_len):
    __write_single_header(args, out, hash_buf, code_len, 1)

def __write_bcm_cert(out, cert):
    offset = 0x1000
    with open(cert, 'rb') as c_f:
        cert_buf = c_f.read()
        out.seek(offset)
        out.write(cert_buf)

def write_header_bcm(cert, out):
   __write_bcm_cert(out, cert) 

def __write_aes(args, out):
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

def __write_sm4(args, out):
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


def write_image(args, out):
    before_header = True if (args.position == 'before_header') else False
    if args.enc == "aes":
        __write_aes(args, out)
    elif args.enc == "sm4":
        __write_sm4(args, out)
    else:
        __write_raw_img(out, args.raw, args.S, before_header)
    if before_header is False: 
        __write_header_hash(out, args.S)

    if args.B:
        print("BCM MODE")
    elif before_header is False:
        __write_header_hash(out, args.S, 1)

def write_cms(args, out, code_len):
    if args.addcms:
        out.seek(code_len + 0x2000)
        if args.position == 'before_header':
            __write_cms(out, args.cms, 0)
        else:
            __write_cms(out, args.cms, 32 - code_len % 16)
        __write_ini(out, args.ini, pss=args.pss)
        __write_crl(out, args.crl)
    return

def write_hash_tree(args, out, code_len):
    hash_tree_offset = code_len + 0x20000 - 0x100   # 128K
    out.seek(hash_tree_offset)
    hash_tree_path = os.path.join(os.path.dirname(args.raw), "hashtree")
    with open(hash_tree_path, "rb") as hash_tree_file:
        hash_tree_content = hash_tree_file.read()
        out.write(hash_tree_content)

def write_header_huawei_address(args, out, code_len):
    partition_size = int(args.partition_size) * 1024 * 1024
    if args.pkt_type == 'large_pkt':
        header_huawei_address_offset = partition_size - 0xC
        out.seek(header_huawei_address_offset)
        out.write(code_len.to_bytes(8, 'little'))
    else:
        header_huawei_address_offset = partition_size - 0x8
        out.seek(header_huawei_address_offset)
        out.write(code_len.to_bytes(4, 'little'))

def write_version(args, out, code_len):
    partition_size = int(args.partition_size) * 1024 * 1024
    version_offset = partition_size - 0x4
    out.seek(version_offset)
    if args.pkt_type == 'large_pkt':
        version = int(1279739216).to_bytes(4, 'little')      # magic LGEP(large packet)
    else:
        version = int(0).to_bytes(4, 'little')
    out.write(version)

def write_extern(args, out, list):
    before_header = True if (args.position == 'before_header') else False
    large_packet = True if (args.pkt_type == 'large_pkt') else False
    code_len = list[0] if before_header else 0
    if before_header:
        __write_header_hash(out, args.S, 0, code_len)
        if args.D:
            __write_header_hash(out, args.S, 1, code_len)
    __add_magic_number_and_file_size(out, args.addcms, before_header, large_packet, code_len)

