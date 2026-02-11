#!/usr/bin/python
# -*- coding: UTF-8 -*-
#----------------------------------------------------------------------------
# Purpose:
# Copyright Technologies Co., Ltd. 2010-2022. All rights reserved.
# Author: fanwenyue
#----------------------------------------------------------------------------

import xml.etree.ElementTree as ET
import hashlib
import argparse
import textwrap
import os


def get_args():
    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
                                     description=textwrap.dedent('''
                                     A tool to generate a image ini file'''))
    parser.add_argument('-in_xml', required=True, dest='inFilePath', help='The xml for get image list')
    parser.add_argument('--hash_list', required=False, help="gen cms image hash_list file", action="store_true")
    parser.add_argument('-hash_dest', required=False, dest='hash_list_path', help='hash_list file dest address')
    parser.add_argument('--hash_update', required=False, dest='new_image_name', help="update image hash to hashlist")
    parser.add_argument('-hash_list_img', required=False, dest='hash_list_img_path', help='hash_list img file path to add new hash')
    return parser.parse_args()


def cal_image_hash(filepath):
    sha256_hash = hashlib.sha256()
    with open(filepath, "rb") as f:
        # Read and update hash string value in blocks of 4K
        for byte_block in iter(lambda: f.read(4096), b""):
            sha256_hash.update(byte_block)
    return sha256_hash.hexdigest()

def cal_fs_image_hash(filepath, roothash):
    sha256_hash = hashlib.sha256()
    with open(filepath, "rb") as f:
        # Read and update hash string value in blocks of 4K
        for byte_block in iter(lambda: f.read(4096), b""):
            sha256_hash.update(byte_block)
    hash_val = sha256_hash.hexdigest() + ";dm-roothash," + roothash
    print(hash_val)
    return hash_val

def gen_ini():
    args = get_args()
    tree = ET.ElementTree(file=args.inFilePath)
    if tree.getroot().tag != 'image_info':
        print("error in input xml file")
    if args.hash_list:
        hash_list_path = os.path.join(args.hash_list_path, ('{}.img'.format('hash-list')))
        if (os.path.exists(hash_list_path)) :
            os.remove(hash_list_path)
        for elem in tree.iter(tag='image'):
            if elem.attrib['tag'] == 'hashlist':
                continue
            position = elem.get('position', 'after_header')
            if position == 'before_header':
                roothash = elem.get('roothash')
                hashVal = cal_fs_image_hash(elem.attrib['path'], roothash)
            else:
                hashVal = cal_image_hash(elem.attrib['path'])
            with open(hash_list_path, 'a+') as f:
                line_elem = [elem.attrib['tag'], hashVal]
                line = '{};'.format(','.join(line_elem))
                f.write(line)
    else:
        for elem in tree.iter(tag='image'):
            position = elem.get('position', 'after_header')
            if position == 'before_header':
                roothash = elem.get('roothash')
                hashVal = cal_fs_image_hash(elem.attrib['path'], roothash)
            else:
                hashVal = cal_image_hash(elem.attrib['path'])
            if hashVal == "":
                return -1
            if 'ini_name' in elem.attrib:
                file_name = os.path.join(elem.attrib['out'], f'{elem.attrib["ini_name"]}.ini')
            else:
                file_name = os.path.join(elem.attrib['out'], ('{}.ini'.format(elem.attrib['tag'])))
            # print(file_name)
            with open(file_name, 'w+') as f:
                line_elem = [elem.attrib['tag'], hashVal]
                line = '{};\n'.format(',   '.join(line_elem))
                f.write(line)
    return 0

def update_hash():
    args = get_args()
    tree = ET.ElementTree(file=args.inFilePath)
    print("update_hash")
    if tree.getroot().tag != 'image_info':
        print("error in input xml file")
    if args.new_image_name:
        hash_list_path = args.hash_list_img_path
        if (os.path.exists(hash_list_path)) :
            for elem in tree.iter(tag='image'):
                if elem.attrib['tag'] == args.new_image_name:
                    hashVal = cal_image_hash(elem.attrib['path'])
                    with open(hash_list_path, 'a+') as f:
                        line_elem = [elem.attrib['tag'], hashVal]
                        line = '{};'.format(','.join(line_elem))
                        f.write(line)
                        print('add',args.new_image_name,'hash val',hashVal,'to',hash_list_path)
        else:
            print("input hashlist file not exist")
            return 1
    return 0

def main():
    args = get_args()
    if args.new_image_name:
        update_hash()
    else:
        gen_ini()

if __name__ == '__main__':
    main()
