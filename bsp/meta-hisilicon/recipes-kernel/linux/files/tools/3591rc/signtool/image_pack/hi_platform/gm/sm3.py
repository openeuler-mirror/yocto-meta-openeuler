#!/usr/bin/env python
#-*- coding: utf-8 -*-
#----------------------------------------------------------------------------
# Purpose:
# Copyright Technologies Co., Ltd. 2010-2025. All rights reserved.
#----------------------------------------------------------------------------
import struct

MASK = 0xFFFFFFFF

def MAX(a, b):
    return (a if a > b else b)

def MIN(a, b):
    return (a if a < b else b)

def ROTL(value, bits):
    shift = (32 - bits) & 0xFFFFFFFF
    shift = shift if shift < 32 else shift % 32
    left_shift = bits if bits < 32 else bits % 32
    result = ((value) << (left_shift))
    #result |=  ((value) >> ( 32 - bits)) if bits <= 32 else 0
    result |=  ((value) >> shift)
    result = result & (0xffffffff)
    return result

def ROTR(value, bits):
    shift = (32 - bits) & 0xFFFFFFFF
    shift = shift if shift < 32 else shift % 32
    right = bits if bits < 32 else bits % 32
    result = (((value) >> (right)) | ((value) << shift))
    result = result & (0xffffffff)
    return result



def uint32_to_uint8(data_out, data_in, data_len):
    i = 0
    for j in range(0, data_len, 4):
        for k in range(0, 4):
            data_out[j + k] = (data_in[i] >> (24 - 8 * k)) & 0xFF
        i = i + 1

def uint8_to_uint32(data_out, data_in, data_len):
    i = 0
    for j in range(0, data_len, 4):
        data_out[i] = 0
        for k in range(0, 4):
            data_out[i] |= data_in[j + k] << (24-8*k)
        data_out[i] = data_out[i] & 0xFFFFFFFF
        i = i + 1

def P0(x):
    result = x ^ ROTL(x, 9) ^ ROTL(x, 17)
    result = result & 0xFFFFFFFF
    return result

def P1(x):
    result = x ^ ROTL(x, 15) ^ ROTL(x, 23)
    result = result & MASK
    return result

def FF(x, y, z, j):
    if j < 16:
        return x ^ y ^ z
    else:
        return (x & y) | (x & z) | (y & z)

def GG(x, y, z, j):
    if j < 16:
        return x ^ y ^ z
    else:
        return ((x & y) | ((MASK ^ x) & z))

def SM3_compress(state, buf):
    A = state[0]
    B = state[1]
    C = state[2]
    D = state[3]
    E = state[4]
    F = state[5]
    G = state[6]
    H = state[7]

    W = [0] * 68
    W_ = [0] * 64
    uint8_to_uint32(W, buf, 64)

    for j in range(0, 68):
        if j >= 16:
            W[j] = P1(W[j - 16] ^ W[j - 9] ^ ROTL(W[j - 3], 15)) ^ ROTL(W[j - 13], 7) ^ W[j - 6]

    for j in range(0, 64):
        W_[j] = W[j] ^ W[j + 4]
    '''    
    for j in range(0, 64):
        print("{0:08x}, ".format(W_[j]), end='')
    print("\n")

    for j in range(0, 64):
        print("{0:08x}, ".format(W[j]), end='')
    print("\n")
    '''
    for j in range(0, 64):
        if j < 16:
            T = 0x79cc4519
        else:
            T = 0x7a879d8a
        SS1 = (ROTL((ROTL(A, 12) + E + ROTL(T, j)) & MASK, 7)) & MASK
        SS2 = SS1 ^ ROTL(A, 12)
        TT1 = (FF(A, B, C, j) + D + SS2 + W_[j]) & MASK
        t1 = GG(E, F, G, j)
        t2 = (H + SS1) & MASK
        TT2 = (t1 + t2 + W[j]) & MASK
        D = C
        C = ROTL(B, 9)
        B = A
        A = TT1
        H = G
        G = ROTL(F, 19)
        F = E
        E = P0(TT2)
        #print("{0:08x}, {1:08x}, {2:08x}, {3:08x}, {4:08x}, {5:08x}, {6:08x}, {7:08x}, {8:08x}, {9:08x}, {10:08x}, {11:08x}, {12:08x}, {13:08x}".format(SS1,SS2,TT1,t1, t2,TT2,A,B,C,D,E,F,G,H))
    state[0] ^= A
    state[1] ^= B
    state[2] ^= C
    state[3] ^= D
    state[4] ^= E
    state[5] ^= F
    state[6] ^= G
    state[7] ^= H
    return 0

def SM3_Init(state, length):
    state[0] = 0x7380166f
    state[1] = 0x4914b2b9
    state[2] = 0x172442d7
    state[3] = 0xda8a0600
    state[4] = 0xa96f30bc
    state[5] = 0x163138aa
    state[6] = 0xe38dee4d
    state[7] = 0xb0fb0e4e
    length[0] = 0
    length[1] = 0

    return 0

def SM3_Update(state, buf, length, cur_len, data_in, data_len):
    tmp_len = data_len
    length[0] += data_len >> 29
    length[1] = (length[1] + (data_len << 3)) & 0xFFFFFFFFFFFFFFFF
    pos = 0

    if (length[1] < (data_len << 3)):
        length[0] += 1

    while tmp_len > 0:
        n = MIN(tmp_len, (64 - cur_len))
    
        for i in range(0, n):
            buf[cur_len + i] = data_in[pos]
            pos += 1
        cur_len += n
        tmp_len -= n

        if cur_len == 64:
            cur_len = SM3_compress(state, buf)

    return cur_len

def SM3_Final(md, state, buf, length, cur_len):
    tmp_length = [0] * 8
    PAD = [0] * 64 
    PAD[0] = 0x80

    uint32_to_uint8(tmp_length, length, 8)

    for i in range(0, 64 - cur_len):
        buf[cur_len + i] = PAD[i]

    if (cur_len >= 56):
        cur_len = SM3_compress(state, buf)
        for i in range(0, 56):
            buf[i] = 0



    for i in range(0, 8):
        buf[56 + i] = tmp_length[i]
    cur_len = SM3_compress(state, buf)

    uint32_to_uint8(md, state, 32)

    return cur_len

def SM3(md, data_in, data_len):
    length = [0] * 2
    state = [0] * 8
    cur_len = 0
    buf = [0] * 64

    cur_len = SM3_Init(state, length)
    
    cur_len = SM3_Update(state, buf, length, cur_len, data_in, data_len)

    cur_len = SM3_Final(md, state, buf, length, cur_len)

def hmac_sm3(key, key_len, data_in, data_len, hmac):
    hashl = [0] * 32
    m = [0] * 128
    
    length = [0] * 2
    state = [0] * 8
    cur_len = 0
    buf = [0] * 64

    for j in range(0, key_len):
        m[j] = key[j] ^ 0x36
    for j in range(key_len, 64):
        m[j] = 0x36
    
    cur_len = SM3_Init(state, length)
    cur_len = SM3_Update(state, buf, length, cur_len, m, 64)
    cur_len = SM3_Update(state, buf, length, cur_len, data_in, data_len)
    cur_len = SM3_Final(hashl, state, buf, length, cur_len)

    for j in range(0, key_len):
        m[j] = key[j] ^ 0x5c
    for j in range(key_len, 64):
        m[j] = 0x5c

    cur_len = SM3_Init(state, length)
    cur_len = SM3_Update(state, buf, length, cur_len, m, 64)
    cur_len = SM3_Update(state, buf, length, cur_len, hashl, 32)
    cur_len = SM3_Final(hmac, state, buf, length, cur_len)

def sm3_pbkdf2(salt, salt_len, data, data_len, cnt, h):
    u = [0] * 100
    hmac = [0] * 32
    t = [0] * 32
    tmp = [0] * 32

    i = 0x00000001

    for j in range(0, salt_len):
        u[j] = salt[j]

    u[salt_len] = (i >> 24) & 0xFF
    u[salt_len + 1] = (i >> 16) & 0xFF
    u[salt_len + 2] = (i >> 8) & 0xFF
    u[salt_len + 3] = i & 0xFF

    for j in range(0, salt_len + 4):
        print("{0:02x}, ".format(u[j]), end="")
    print("\n");


    print("cnt = {0}".format(cnt))
    for j in range(0, cnt):
        if j == 0:
            hmac_sm3(data, data_len, u, salt_len + 4, hmac)
        else:
            hmac_sm3(data, data_len, t, 32, hmac)

        for k in range(0, 32):
            t[k] = hmac[k]
            tmp[k] ^= hmac[k]
    
    for j in range(0, 16):
        h[j] = tmp[j]

def test():
    length = [0] * 2
    state = [0] * 8
    cur_len = 0
    buf = [0] * 64
    data = [0] * 64
    hmac = [0] * 32 
    cur_len = SM3_Init(state, length)

    for i in range(0, 64):
        data[i] = i

    for i in range(0, 8):
        print("{0:08x}, ".format(state[i]), end = "")
    print("\n")
    for i in range(0, 64):
        buf[i] = i    

    cur_len = SM3_Update(state, buf, length, cur_len, data, 20)
    
    for i in range(0, 8):
        print("{0:08x}, ".format(state[i]), end = "")
    print("\n")
    for i in range(0, 64):
        print("{0:02x}, ".format(buf[i]), end = "")
    print("\n")
    for i in range(0, 2):
        print("{0:x}, ".format(length[i]), end = '')
    print("\n")
    print("{0:x}".format(cur_len))
    cur_len = SM3_Update(state, buf, length, cur_len, data, 24)
     
    for i in range(0, 8):
        print("{0:08x}, ".format(state[i]), end = "")
    print("\n")
    for i in range(0, 64):
        print("{0:02x}, ".format(buf[i]), end = "")
    print("\n")
    for i in range(0, 2):
        print("{0:x}, ".format(length[i]), end = '')
    print("\n")
    print("{0:x}".format(cur_len))
    cur_len = SM3_Final(hmac, state, buf, length, cur_len)

    for i in range(0, 32):
        print("{0:02x}, ".format(hmac[i]), end = "")
    print("\n")

def main():
    salt = [0] * 32
    data = [0xed, 0x8f, 0x54, 0xbb, 0xbf, 0x73, 0x05, 0x92, 0x7c, 0xbd, 0x0a, 0xd1, 0x6a, 0x02, 0x95, 0x07]
    h = [0] * 32
    test()
    sm3_pbkdf2(salt, 32, data, 16, 1000, h)

    for i in range(0, 32):
        print("{0:x}".format(h[i]))
    print("\n")
if __name__ == "__main__" :
    main()
