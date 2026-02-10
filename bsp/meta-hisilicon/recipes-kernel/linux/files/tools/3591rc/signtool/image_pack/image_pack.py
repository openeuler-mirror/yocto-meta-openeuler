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

from tools import *

def get_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
                                     description=textwrap.dedent('''
                                     A tool to pack image with new structure'''))
    parser.add_argument('-raw_img', required=False, dest='raw', help='INPUT: The raw image')
    parser.add_argument('-out_img', required=False, dest='out',
                        help='OUTPUT: The processed image. Filename can be same to input image')
    parser.add_argument('-platform', required=False, dest='platform',
                        choices=['hi1910', 'ascend610', 'ascend610lite', 'hi1910p', 'hi1910prc', 'bs9sx1a', 'hi1111A', 'hi1910B', 'hi1910Brc', 'ascend', 'as31xm1', 'hn920', 'hi1980D'],
                        help='INPUT: platform : hi1910/hi1910p/ascend610/ascend610lite/bs9sx1a/hi1111A/hi1910B/hi1910Brc/ascend/as31xm1/hn920/hi1980D/hi1910prc')

    # input for soc
    parser.add_argument('-root', required=False, dest='root', help='INPUT: CA cert, Parse N/E from it')
    parser.add_argument('--root_raw', help='root key whether is pem file', action="store_true")
    parser.add_argument('-cert', required=False, dest='cert', help='INPUT: The soc cert')
    parser.add_argument('-sig', required=False, dest='sig', help='INPUT: The soc signature')

    # input for bcm
    parser.add_argument('-bcmcert', required=False, dest='bcmcert', help='INPUT: The bcm cert')
    parser.add_argument('-G', help="chose GCM mode", action = "store_true")
    parser.add_argument('-sm', help="choose sm mode", action = "store_true")

    # input for cms
    parser.add_argument('-cms', required=False, dest='cms', help='INPUT: The cms file')
    parser.add_argument('-ini', required=False, dest='ini', help='INPUT: The ini file')
    parser.add_argument('-crl', required=False, dest='crl', help='INPUT: The crl file')

    # 1910_version
    parser.add_argument('-version', required=False, dest='ver', help='INPUT: The version number')

    # flag cmd
    parser.add_argument('--addsoc', help="choose whether add soc", action="store_true")
    parser.add_argument('-S', help="choose whether Onchiprom", action="store_true")

    parser.add_argument('-D', help="choose whether double ", action="store_true")
    parser.add_argument('-B', help="choose whether bcm", action="store_true")
    parser.add_argument('-V', help="choose verifyboot mode", action="store_false")
    parser.add_argument('--addcms', help="choose whether add cms", action="store_true")

    parser.add_argument('-position',  required=False, choices=['before_header', 'after_header'], help='INPUT: The relative position of raw_img and head')
    parser.add_argument('-pkt_type',  required=False, choices=['normal_pkt', 'large_pkt'], nargs='?', const='normal_pkt', default='normal_pkt', help='INPUT: The large_pkt support larger than 4GB packet')
    parser.add_argument('-partition_size',  required=False, nargs='?', help='INPUT: The rootfs/app.img partition size(M)')

    # encrypt related
    parser.add_argument('-enc', choices=['aes', 'sm4'], help="enc mode")
    parser.add_argument('-key', required=False, dest='key', help='INPUT: The encrypt key')
    parser.add_argument('--pss', help="choose the code signature algo", action="store_true")

    # TA related
    parser.add_argument('--ta', required=False, dest='ta', help='INPUT: The name of optee signed TA, like xxxx.ta')
    parser.add_argument('--ta_path', required=False, dest='ta_path', help='INPUT: The path of TA and signed TA ELF')

    # nvcnt
    parser.add_argument('-nvcnt', required=False, dest='nvcnt', nargs='?', const=None, help='INPUT: nvcnt for driver images')
    parser.add_argument('-tag', required=False, dest='tag', nargs='?', const=None, help='INPUT: tag for driver images')
    return parser.parse_args()

def main():
    if args.ta:
        sh_ta = os.path.join(args.ta_path, args.ta)
        st_ta = os.path.join(args.ta_path, args.ta[:-3] + '.stripped.elf')
        tmp_file = os.path.join(args.ta_path, args.ta + '%s.tmp' % args.raw)
        with open(tmp_file, "wb+") as o_f:
            with open(sh_ta, "rb") as ta_h:
                with open(st_ta, "rb") as ta_t:
                    ta = ta_h.read()
                    o_f.write(ta)
                    ta_t.seek(-552, 2); # siglen + sizeof(struct module_signature) + sizeof(MODULE_SIG_STRING)
                    sig = ta_t.read(512) # RSA4096 sig len
                    o_f.write(sig)
                    tl = construct_ta_tailer()
                    o_f.write(tl)

        shutil.copyfile(tmp_file, sh_ta)
    elif args.position == 'before_header':
        with open(args.raw, "rb") as f:
            hash_buf = cal_image_hash(f)
            code_len = get_filelen(f)
            tmp_file = args.out + 'tmp'
            with open(tmp_file, 'wb+') as o_f:
                #write image
                platforms.write_image(args, o_f)
                #write huawei header, customer header
                platforms.write_header_huawei(args, o_f, hash_buf, code_len)
                if args.D:
                    platforms.write_header_customer(args, o_f, hash_buf, code_len)
                #write CMS bootup.ini CRL
                platforms.write_cms(args, o_f, code_len)
                #write hash_tree
                platforms.write_hash_tree(args, o_f, code_len)
                #write huawei header address, version
                platforms.write_header_huawei_address(args, o_f, code_len)
                platforms.write_version(args, o_f, code_len)
                platforms.write_extern(args, o_f, [code_len])

        shutil.copyfile(tmp_file, args.out)
    else:
        with open(args.raw, "rb") as f:
            hash_buf = cal_image_hash(f)
            code_len = get_filelen(f)

            tmp_file = args.out + '.tmp'
            with open(tmp_file, 'wb+') as o_f:
                platforms.write_header_huawei(args, o_f, hash_buf, code_len)
                if args.D:
                    platforms.write_header_customer(args, o_f, hash_buf, code_len)
                elif args.B:
                    print(args.bcmcert)
                    platforms.write_header_bcm(args.bcmcert, o_f)
                platforms.write_image(args, o_f)
                platforms.write_cms(args, o_f, code_len)
                platforms.write_extern(args, o_f, [hash_buf, code_len])

        shutil.copyfile(tmp_file, args.out)
    if os.path.exists(tmp_file):
        os.remove(tmp_file)


if __name__ == '__main__':
    args = get_args()
    if not args.partition_size:
        args.partition_size = '1024' if args.platform == 'as31xm1' else '2048'
    if args.platform == 'hi1910':
        import hi_platform.platform_hi1910 as platforms
    elif args.platform == 'ascend610' or args.platform == 'ascend610lite' or args.platform == 'hi1910p' or args.platform == 'bs9sx1a' or \
         args.platform == 'hi1910prc':
        import hi_platform.platform_ascend610 as platforms
    elif args.platform == 'hi1111A' or args.platform == 'hi1910B' or args.platform == 'hi1910Brc' or args.platform == 'ascend' or \
         args.platform == 'as31xm1' or args.platform == 'hn920' or args.platform == 'hi1980D':
        import hi_platform.platform_hi1111A as platforms
    elif args.ta == '':
        raise ValueError("error platform type {0}".format(args.platform))
    main()
