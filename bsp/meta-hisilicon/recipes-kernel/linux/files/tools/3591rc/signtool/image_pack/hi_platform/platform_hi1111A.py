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
#     uint8_t reserved[20]
#     uint32_t head_len; /*don't check in secure boot*/
#     uint32_t user_len; /*don't check in secure boot*/
#     uint8_t  user_define_data[32]; /*don't check in secure boot*/
#     uint8_t  code_hash[HASH_SIZE]; /*image hash value, don't check in secure boot*/
#     uint32_t sub_key_cert_offset;
#     uint32_t subcert_len;     /* subkey cert len */
#     uint32_t roothash_alg;    /* root hash hash : [15:0] 0x0 SHA256, 0x20 SM3*/
#     uint32_t img_sign_algo; /*[15:0]Hash algorithm;0x0-SHA256,others: reserved
#                           [31:22](10bit)signature parasms.RSA_PKCS1-0,RSA_PSS standsfor salt length(byte)
#                           [21:16](6bit)signature algorithm.0x0:RSA_PKCS1; 0x1: RSA_PSS*/
#     uint32_t root_pubkey_len; /*rootpukkey length,512 bytes*/
#     uint8_t root_pubkey_n[RSA_ROOTKEY_WIDTH_BYTES]; /*N value, length is RootPubKLen*/
#     uint8_t root_pubkey_e[RSA_ROOTKEY_WIDTH_BYTES]; /*E valuse and fixed to 65537*/
#     uint32_t img_offset; /*addr offset between code_image*/
#     uint32_t img_sign_obj_len;
#     uint32_t sign_offset;
#     uint32_t sign_len;    /* sign len */
#     uint32_t encrypt_flag;
#     uint32_t encrypt_algo;
#     uint8_t  derive_seed[SCB_DERIVE_SEED_LEN];
#     uint32_t km_iretation_cnt; /* km derive cnt  */
#     uint8_t  encrypt_iv[SCB_ENCRPT_IV_LEN];
#     uint8_t  encrypt_tag[16];
#     uint8_t  encrypt_add[16];
#     uint8_t  encrypt_tag[16];  /*16 bytes reserved*/
#     uint8_t  rsv[88]; /* rsv for hydra */
#     uint32_t h2c_lic_mode;   /* h2c mode label:0x41544941 - enable; other -disable  */
#     uint32_t h2c_cer_len;
#     uint32_t h2c_cer_offset;
#     uint32_t root_pubkeyinfo;
#     uint8_t rsv[20];             /* todo use for align */
#     uint32_t head_magic; /*0x33cc33cc*/
#     uint8_t  head_hash[HASH_SIZE];
# } SE_IMAGE_HEAD;

def __construct_header(N_buf, E_buf, hash_buf, code_len, suffix, head_type, version, nvcnt, tag, before_header=False, 
                       large_packet=False, enc=False, pss=False, bcm=False, verifymode = True, gcm = False, gm = False):

    # if rootfs/app.img is large_packet(>4G), stub code_len 0 (invalid value)
    code_len = 0 if before_header and large_packet else code_len
    header_base = 0x1000 if head_type else 0
    zero_bytes_32 = int(0).to_bytes(32, 'big') if sys.version > '3' else to_bytes(0, 32)
    s = struct.Struct('I20sII32s32sIIIII512s512sIIIIII32sI16s16s16s88sIIII20sI32s16s8s16s4I72s')
    preamble = 0x55AA55AA
    rev0 = int(0).to_bytes(20, 'big')
    head_len = 0x600
    user_len = 0x0
    user_define_data = int(0).to_bytes(32, 'big')
    code_hash = hash_buf
    sub_key_cert_offset = 0x600 + header_base
    sub_cert_len = 0x618
    uw_rootkey_alg = 0x0
    img_sign_algo = 0x8010000
    root_pubkey_len = 512
    root_pubkey_n = N_buf
    root_pubkey_e = E_buf
    img_offset = 0 if before_header else 0x2000
    img_sign_obj_len = code_len
    sign_offset = header_base + 0xE00
    sign_len = 512
    code_encrypt_flag = 0x5AA55AA5 if enc else 0xFFFFFFFF
    code_encrypt_algo = 0x2
    derive_seed = zero_bytes_32
    km_ireation_cnt = 1000
    code_encrypt_iv = zero_bytes_32[:16]
    code_encrypt_tag = zero_bytes_32[:16]
    code_encrypt_add = zero_bytes_32[:16]
    rsv1 = int(0).to_bytes(88, 'big')
    rsv2 = int(0).to_bytes(20, 'big')

    if bcm:
        h2c_enable = 0x41544941
        h2c_cert_len = 0x800
        h2c_cert_offset = 0x1000
    else:
        h2c_enable = 0xA5A55555
        h2c_cert_offset = 0
        h2c_cert_len = 0
    root_pubkeyinfo = 0
    head_magic = 0x33CC33CC
    head_hash = zero_bytes_32 # fill in zero first, it will be calculated and filled later
    cms_flag = int(0).to_bytes(16, 'big')
    code_nvcnt = int(0).to_bytes(8, 'big')
    if tag == None:
        code_tag = int(0).to_bytes(16, 'big')
    else:
        code_tag = bytes(str(tag),'ascii')
    ver_value = list(map(int, version.split('.'), [16] * 5))
    ver_value[3] = (ver_value[3] << 16) | (ver_value[4] & 0xFFFF)
    padding_val = "ff" * 0x48 # fixed padding at the end of header
    padding = binascii.a2b_hex(padding_val)
    pack_list = (preamble, rev0, head_len, user_len, user_define_data, code_hash,
                 sub_key_cert_offset, sub_cert_len, uw_rootkey_alg, img_sign_algo, root_pubkey_len, root_pubkey_n,
                 root_pubkey_e, img_offset, img_sign_obj_len, sign_offset, sign_len, code_encrypt_flag, code_encrypt_algo,
                 derive_seed, km_ireation_cnt, code_encrypt_iv, code_encrypt_tag, code_encrypt_add, rsv1, h2c_enable,
                 h2c_cert_len, h2c_cert_offset, root_pubkeyinfo, rsv2, head_magic, head_hash, cms_flag, code_nvcnt,
                 code_tag, ver_value[0], ver_value[1], ver_value[2], ver_value[3], padding)
    header = s.pack(*pack_list)
    return header

def __get_filelen(f):
    f.seek(0, 2)
    length = f.tell()
    f.seek(0)
    return length

def __write_header(out, header, suffix=False, head_type=0, code_len=0, before_header=False):
    header_base = 0x1000 if head_type else 0
    header_base = (header_base + code_len) if before_header else header_base
    offset = (0xC000 + header_base) if suffix else header_base
    out.seek(offset)
    out.write(header)

def __write_header_hash(out, suffix=False, head_type=0, sm=False, code_len=0, before_header=False):
    header_base = 0x1000 if head_type else 0
    offset = header_base if (suffix or not before_header) else header_base + code_len
    out.seek(offset)
    header = out.read(0x560)
    if sm == False:
        out.write(cal_bin_hash(header))
    else:
        out.write(sm3_cal(header))

def __write_cert(out, cert, suffix=False, head_type=0):
    header_base = 0x1000 if head_type else 0
    offset = (0xC000 + header_base + 0x600) if suffix else (header_base + 0x600)
    padding_val = "ff" * 0x1E8 # fixed padding at the end of cert
    padding = binascii.a2b_hex(padding_val)
    with open(cert, 'rb') as c_f:
        cert_buf = c_f.read()
        cert_buf += padding
        out.seek(offset)
        out.write(cert_buf)

def __write_signature(out, sig, suffix=False, head_type=0):
    header_base = 0x1000 if head_type else 0
    offset = (0xC000 + header_base + 0xE00) if suffix else (header_base + 0xE00)
    with open(sig, 'rb') as s_f:
        sig_buf = s_f.read()
        out.seek(offset)
        out.write(sig_buf)

    signed_size = os.path.getsize(sig)
    out.seek(header_base + 0x488)
    raw_signed_size = struct.pack('I', signed_size)
    out.write(raw_signed_size)

# image encrypt operation:
def __img_key_and_nonce_gen(key_path, key_len):
    from Crypto import Random
    salt = Random.get_random_bytes(32)
    print("salt :{}".format(binascii.hexlify(salt)))

    with open(key_path, 'rb') as f:
        key = f.read()
    key_rvs = key[::-1]
    print("key_rvs = {}".format(binascii.hexlify(key_rvs)))

    if key_len == 32:  #pbkdf2-sha256
        from Crypto.Protocol.KDF import PBKDF2
        from Crypto.Hash import SHA256, HMAC
        key_der = PBKDF2(key_rvs, salt, key_len, 1000, prf=lambda p,s: HMAC.new(p, s, SHA256).digest())
        nonce = Random.get_random_bytes(12)
        print("key_der = {}".format(binascii.hexlify(key_der)))
        return key_der, salt, nonce
    elif key_len == 16: #pbkdf2-sm3
        import gm.sm3 as gm_sm3
        sm3_key = [0] * len(key_rvs)
        key_der = gm_sm3.sm3_pbkdf2(salt, len(salt), key_rvs, len(key_rvs), 1000, sm3_key)

        print("key_der = {}".format(binascii.hexlify(key_der)))

        iv = Random.get_random_bytes(16)
        return key_der, salt, iv

def __header_write_salt_and_iv(out, salt, nonce="", counter=0, iv="", head_type=0, mode = False):
    offset = 0x148C if head_type else 0x48C
    out.seek(offset)
    out.write(salt)

    offset += 36
    out.seek(offset)
    if mode :
        out.write(nonce)
    else:
        if nonce != "":
            offset += 4
            out.seek(offset)
            out.write(nonce)
            counter_bin = counter.to_bytes(4, 'big') if sys.version > '3' else to_bytes(counter, 4)
            out.write(counter_bin)
        elif iv != "":
            out.write(iv)

def __write_raw_img(out, raw, suffix=False, before_header=False):
    offset = 0 if suffix or before_header else 0x2000
    out.seek(offset)
    with open(raw, 'rb') as raw_file:
        for byte_block in iter(lambda: raw_file.read(4096), b""):
            out.write(byte_block)

def __aes_encrypt_and_write_raw_img(out, key, nonce, counter, raw, mode = True, suffix=False, verifymode = True, Double_mode = True):
    offset = 0 if suffix else 0x2000
    out.seek(offset)
    cipher = ''
    with open(raw, 'rb') as raw_file:
        from Crypto.Cipher import AES
        if mode == False:
            cipher = AES.new(key, AES.MODE_CTR, nonce=nonce, initial_value=counter)
        else :
            cipher = AES.new(key, AES.MODE_GCM, nonce=nonce)

        if verifymode == False:
            data = raw_file.read(256)
            out.write(data)
        for byte_block in iter(lambda: raw_file.read(4096), b""):
            byte_block_ct = cipher.encrypt(byte_block)
            out.write(byte_block_ct)

        if mode == True:
            tag = cipher.digest()
            out.seek(0x4C0)
            out.write(tag)
            if Double_mode:
                out.seek(0x14C0)
                out.write(tag)
            print("\ntag = ", tag)


def __sm4_encrypt_and_write_raw_img(out, key, iv, raw, suffix=False, verifymode = True):
    offset = 0 if suffix else 0x2000
    out.seek(offset)
    print("sm4_key:")
    print(key.hex())

    with open(raw, 'rb') as raw_file:
        from gmssl.sm4 import CryptSM4, SM4_ENCRYPT
        crypt_sm4 = CryptSM4()
        crypt_sm4.set_key(key, SM4_ENCRYPT)

        if verifymode == False:
            data = raw_file.read(256)
            out.write(data)
        pt = raw_file.read()
        ct = crypt_sm4.crypt_cbc(iv, pt)
        out.write(ct)


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
    return header

def __write_cms(out, cms, aligned_bytes):
    with open(cms, 'rb') as cf:
        length = __get_filelen(cf)
        header = __construct_cms_header('cms', length)
        __add_in_tail(aligned_bytes, cf, out, header, length)

def __write_ini(out, ini):
    with open(ini, 'rb') as ifile:
        length = __get_filelen(ifile)
        header = __construct_cms_header('ini', length)
        __add_in_tail(16 * 1024, ifile, out, header, length)

def __write_crl(out, crl):
    with open(crl, 'rb') as af:
        length = __get_filelen(af)
        header = __construct_cms_header('crl', length)
        __add_in_tail(2 * 1024, af, out, header, length)

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
    header = __construct_header(N_buf, E_buf, hash_buf, code_len, args.S, head_type, args.ver, args.nvcnt,
                                args.tag, before_header, large_packet, args.enc, pss=args.pss, bcm=args.B,
                                verifymode = args.V, gcm = args.G, gm = args.sm)
    __write_header(out, header, args.S, head_type, code_len, before_header)

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

def write_image(args, out):
    before_header = True if (args.position == 'before_header') else False
    if args.enc :
            key_der, salt, iv = __img_key_and_nonce_gen(args.key, 16)
            __header_write_salt_and_iv(out, salt, iv=iv, head_type=0)
            if args.B:
                print("BCM mode")
            elif args.D:
                __header_write_salt_and_iv(out, salt, iv=iv, head_type=1)
            __sm4_encrypt_and_write_raw_img(out, key_der, iv, args.raw, suffix = args.S, verifymode = args.V)
    else:
        __write_raw_img(out, args.raw, args.S, before_header)
    if before_header is False:
        __write_header_hash(out, args.S, 0, args.sm)

    if args.B:
        print("BCM MODE")
    elif before_header is False and args.D:
        __write_header_hash(out, args.S, 1, args.sm)

def write_cms(args, out, code_len):
    if args.addcms:
        out.seek(code_len + 0x2000)
        if args.position == 'before_header':
            __write_cms(out, args.cms, 0)
        else:
            __write_cms(out, args.cms, 32 - code_len % 16)
        __write_ini(out, args.ini)
        __write_crl(out, args.crl)

def __add_magic_number_and_file_size(args, out, cms_flag, suffix=False, code_len=0, before_header=False, large_packet=False):
    if cms_flag and suffix:
        raise RuntimeError("Invalid Param: --addcms and -S can't input in the same time.")

    out.seek(0, 2)
    # if before_header img code_len >= 4G, img_len = 0 (not used)
    fileSize = 0 if before_header and (out.tell() >= 0x100000000) else out.tell()
    s = struct.Struct('QI')
    if cms_flag:
        value = (0xABCD1234AA55AA55, fileSize)
    else:
        value = (0x0, fileSize)
    stream = s.pack(*value)
    # print(binascii.hexlify(stream))
    offset = code_len + 0x580 if before_header else 0x580
    out.seek(offset, 0)
    out.write(stream)

    # Write additional nvcnt to head
    # nvcnt_offset : 0x0x590
    # [
    #     U32 nvcnt_magic : 0x5A5AA5A5
    #     U32 nvcnt
    # ] nvcnt_s
    if args.nvcnt:
        s = struct.Struct('II')
        nvcnt_magic = 0x5A5AA5A5
        pack_list = (nvcnt_magic, int(args.nvcnt))
        nvcnt_s = s.pack(*pack_list)
        nvcnt_offset = code_len + 0x590 if before_header else 0x590
        out.seek(nvcnt_offset)
        out.write(nvcnt_s)

    if before_header:
        offset = code_len + 0x4E0 if before_header else 0x4E0
        out.seek(offset, 0)
        out.write(code_len.to_bytes(8, 'little'))


def write_extern(args, out, list):
    before_header = True if (args.position == 'before_header') else False
    code_len = list[0] if before_header else 0
    if before_header:
        __write_header_hash(out, args.S, 0, args.sm, code_len, before_header)
        if args.D:
            __write_header_hash(out, args.S, 1, args.sm, code_len, before_header)
    __add_magic_number_and_file_size(args, out, args.addcms, False, code_len, before_header)
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