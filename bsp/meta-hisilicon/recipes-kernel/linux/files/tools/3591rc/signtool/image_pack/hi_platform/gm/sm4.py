#!/usr/bin/env python
#-*- coding: utf-8 -*-
#----------------------------------------------------------------------------
# Purpose:
# Copyright Technologies Co., Ltd. 2010-2025. All rights reserved.
#----------------------------------------------------------------------------
import struct

Sbox = [
     0xd6,0x90,0xe9,0xfe,0xcc,0xe1,0x3d,0xb7,0x16,0xb6,0x14,0xc2,0x28,0xfb,0x2c,0x05,
     0x2b,0x67,0x9a,0x76,0x2a,0xbe,0x04,0xc3,0xaa,0x44,0x13,0x26,0x49,0x86,0x06,0x99,
     0x9c,0x42,0x50,0xf4,0x91,0xef,0x98,0x7a,0x33,0x54,0x0b,0x43,0xed,0xcf,0xac,0x62,
     0xe4,0xb3,0x1c,0xa9,0xc9,0x08,0xe8,0x95,0x80,0xdf,0x94,0xfa,0x75,0x8f,0x3f,0xa6, 
     0x47,0x07,0xa7,0xfc,0xf3,0x73,0x17,0xba,0x83,0x59,0x3c,0x19,0xe6,0x85,0x4f,0xa8,
     0x68,0x6b,0x81,0xb2,0x71,0x64,0xda,0x8b,0xf8,0xeb,0x0f,0x4b,0x70,0x56,0x9d,0x35,
     0x1e,0x24,0x0e,0x5e,0x63,0x58,0xd1,0xa2,0x25,0x22,0x7c,0x3b,0x01,0x21,0x78,0x87,
     0xd4,0x00,0x46,0x57,0x9f,0xd3,0x27,0x52,0x4c,0x36,0x02,0xe7,0xa0,0xc4,0xc8,0x9e,
     0xea,0xbf,0x8a,0xd2,0x40,0xc7,0x38,0xb5,0xa3,0xf7,0xf2,0xce,0xf9,0x61,0x15,0xa1,
     0xe0,0xae,0x5d,0xa4,0x9b,0x34,0x1a,0x55,0xad,0x93,0x32,0x30,0xf5,0x8c,0xb1,0xe3,
     0x1d,0xf6,0xe2,0x2e,0x82,0x66,0xca,0x60,0xc0,0x29,0x23,0xab,0x0d,0x53,0x4e,0x6f,
     0xd5,0xdb,0x37,0x45,0xde,0xfd,0x8e,0x2f,0x03,0xff,0x6a,0x72,0x6d,0x6c,0x5b,0x51,
     0x8d,0x1b,0xaf,0x92,0xbb,0xdd,0xbc,0x7f,0x11,0xd9,0x5c,0x41,0x1f,0x10,0x5a,0xd8,
     0x0a,0xc1,0x31,0x88,0xa5,0xcd,0x7b,0xbd,0x2d,0x74,0xd0,0x12,0xb8,0xe5,0xb4,0xb0,
     0x89,0x69,0x97,0x4a,0x0c,0x96,0x77,0x7e,0x65,0xb9,0xf1,0x09,0xc5,0x6e,0xc6,0x84,
     0x18,0xf0,0x7d,0xec,0x3a,0xdc,0x4d,0x20,0x79,0xee,0x5f,0x3e,0xd7,0xcb,0x39,0x48]

CK = [0x00070E15,0x1C232A31,0x383F464D,0x545B6269,
    0x70777E85,0x8C939AA1,0xA8AFB6BD,0xC4CBD2D9,
    0xE0E7EEF5,0xFC030A11,0x181F262D,0x343B4249,
    0x50575E65,0x6C737A81,0x888F969D,0xA4ABB2B9,
    0xC0C7CED5,0xDCE3EAF1,0xF8FF060D,0x141B2229,
    0x30373E45,0x4C535A61,0x686F767D,0x848B9299,
    0xA0A7AEB5,0xBCC3CAD1,0xD8DFE6ED,0xF4FB0209,
    0x10171E25,0x2C333A41,0x484F565D,0x646B7279]

print("{0:x} {1:x}".format(Sbox[1], Sbox[15]))

def Rotl(value, bits):
    result = (((value) << (bits)) | ((value) >> ( 32 - bits)))
    result = result & (0xffffffff)
    return result

def ByteSub(index):
    result = Sbox[(index >> 24) & 0xFF] << 24 & 0xFFFFFFFF
    result = result ^ ((Sbox[(index >> 16) & 0xFF] << 16) & 0xFFFFFFFF)
    result = result ^ ((Sbox[(index >> 8) & 0xFF] << 8) & 0xFFFFFFFF)
    result = result ^ ((Sbox[index & 0xFF]) & 0xFFFFFFFF)
    result = result & (0xffffffff)
    return result

def L2(data_in):
    out = ((data_in) ^ (Rotl(data_in,13)) ^ (Rotl(data_in,23)))
    return out

def L1(data_in):
    out = ((data_in) ^ (Rotl(data_in,2)) ^ (Rotl(data_in,10)) ^ (Rotl(data_in,18)) ^ (Rotl(data_in,24)))
    return out

def SM4Operation(Input, rk):
    x0 = Input[0]
    x1 = Input[1]
    x2 = Input[2]
    x3 = Input[3]

    for r in range(0, 32, 4):
        mid = x1^x2^x3^rk[r + 0]
        mid = ByteSub(mid)
        x0 ^= L1(mid)

        mid = x2^x3^x0^rk[r + 1]
        mid = ByteSub(mid)
        x1 ^= L1(mid)

        mid = x3^x0^x1^rk[r + 2]
        mid = ByteSub(mid)
        x2 ^= L1(mid)

        mid = x0^x1^x2^rk[r + 3]
        mid = ByteSub(mid)
        x3 ^= L1(mid)
    return x3, x2, x1, x0

def SM4KeyExt(Key, rk, CryptFlag):
    x0 = Key[0]
    x1 = Key[1]
    x2 = Key[2]
    x3 = Key[3]

    x0 ^= 0xa3b1bac6
    x1 ^= 0x56aa3350
    x2 ^= 0x677d9197
    x3 ^= 0xb27022dc    

    for r in range(0, 32, 4):
        mid = x1^x2^x3^CK[r + 0]
        mid = ByteSub(mid)
        x0 = x0 ^ L2(mid)
        rk[r + 0] = x0

        mid = x2^x3^x0^CK[r + 1]
        mid = ByteSub(mid)
        x1 ^= L2(mid)
        rk[r + 1] = x1

        mid = x3^x0^x1^CK[r + 2]
        mid = ByteSub(mid)
        x2 ^= L2(mid)
        rk[r + 2] = x2

        mid = x0^x1^x2^CK[r + 3]
        mid = ByteSub(mid)
        x3 ^= L2(mid)
        rk[r + 3] = x3

    if CryptFlag == 1:
        for r in range (0, 16):
            mid = rk[r]
            rk[r] = rk[31 - r]
            rk[31 - r] = mid


def SM4_Encrypt(pKey, pDataIn):
    m_rk = [0] * 32
    SM4KeyExt(pKey, m_rk, 0)
    
    return SM4Operation(pDataIn, m_rk)

def SM4_Decrypt(pKey, pDataIn):
    m_rk = [0] * 32
    SM4KeyExt(pKey, m_rk, 1)
    
    return SM4Operation(pDataIn, m_rk)

def sm4_cbc_op(data_in, iv_in, key_in, flag = 0):
    data_in_len = len(data_in)
    if data_in_len % 16 != 0 :
        raise RuntimeError("wrong data size {0}".format(data_in_len))
    
    pos = 0
    block_size = data_in_len // 16
    padding_size = 16 - data_in_len % 16
    padding_data = [padding_size] * padding_size 
    data_in_padding = data_in
    for i in range(0, 16):
        tmp = struct.pack("B", padding_data[i])
        data_in_padding = data_in_padding + tmp
    #padding = struct.pack(">16B", padding) 
    out = b''
    
    iv = [0] * 4
    key = [0] * 4    
    print(type(iv))
    iv[0], iv[1], iv[2], iv[3], = struct.unpack(">IIII", iv_in[0:16])
    key[0], key[1], key[2], key[3], = struct.unpack(">IIII", key_in[0:16])
    tmp_out = iv[0:4]
    data = [0] * 4
    print("key = {0}".format(key)) 
    #print("{0:x} {1:x} {2:x} {3:x}".format(tmp_out[0], tmp_out[1], tmp_out[2], tmp_out[3]))
    for i in range(0, block_size + 1):
        data[0], data[1], data[2], data[3], = struct.unpack(">IIII", data_in_padding[pos : pos + 16])
        #print("data = {0}".format(data))
        data[0] = tmp_out[0] ^ data[0]
        data[1] = tmp_out[1] ^ data[1]
        data[2] = tmp_out[2] ^ data[2]
        data[3] = tmp_out[3] ^ data[3]
        
        #print("data = {0}".format(data))
        tmp_out[0], tmp_out[1], tmp_out[2], tmp_out[3] = SM4_Encrypt(key, data) if flag == 0 else SM4_Decrypt(key, data) 
        
        pos = pos + 16     
        
        #print("{0:x} {1:x} {2:x} {3:x}".format(tmp_out[0], tmp_out[1], tmp_out[2], tmp_out[3]))
        b_out = struct.pack(">IIII", tmp_out[0], tmp_out[1], tmp_out[2], tmp_out[3])
        #print("b_out = {0}".format(tmp_out)) 
        out = out + b_out
        
    return out

def main():
    key = [0x01234567, 0x89abcdef, 0xfedcba98, 0x76543210]
    data_in = [0x01234567, 0x89abcdef, 0xfedcba98, 0x76543210]

    enc_out = [0] * 8
    dec_out = [0] * 8

    iv = [0] * 4

    b_data_in = struct.pack(">IIII", data_in[0], data_in[1], data_in[2], data_in[3])
    b_key = struct.pack(">IIII", key[0], key[1], key[2], key[3])
    b_iv = struct.pack(">IIII", iv[0], iv[1], iv[2], iv[3])

    b_data_in = b_data_in + b_data_in

    b_enc_out = sm4_cbc_op(b_data_in, b_iv, b_key, 0)
    
    tmp = struct.unpack(">IIIIIIII", b_enc_out[0:32])

    print("ecb enc:")
    for i in range(0, 8):
        print("0x{0:08x}".format(tmp[i]))

    b_dec_out = sm4_cbc_op(b_enc_out, b_iv, b_key, 1)
    tmp = struct.unpack(">IIIIIIII", b_dec_out[0:32])
    print("ecb dec:")
    for i in range(0, 8):
        print("0x{0:08x}".format(tmp[i]))
    from gmssl.sm4 import CryptSM4, SM4_ENCRYPT
    crypt_sm4 = CryptSM4()
    crypt_sm4.set_key(b_key, SM4_ENCRYPT)
    ct = crypt_sm4.crypt_cbc(b_iv, b_data_in)
    ct_enc_out = [0] * 4
    tmp = struct.unpack(">IIIIIIII", ct[0:32])

    print("ecb enc:")
    for i in range(0, 8):
        print("0x{0:08x}".format(tmp[i]))



if __name__ == "__main__":
    main()
