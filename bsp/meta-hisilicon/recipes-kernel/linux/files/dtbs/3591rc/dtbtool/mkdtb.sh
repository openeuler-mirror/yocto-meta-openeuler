#!/bin/bash
# Feature:
# Copyright Technologies Co., Ltd. 2010-2018. All rights reserved.
# Compile all the input dts-files in dts_src_dir to dtb-files
# and put the output dtb-files into dtb_out_dir.
set -e
function print_help()
{
cat<<EOF >&2
Usage:
	$0 <dtb_out_dir> <dts_src_dir> <dts_file_list>
EOF
}

if [ $# -le 2 ]; then
	print_help
	exit 1
fi

dtb_out_dir=$1
dts_src_dir=$2

if [ -d "$dtb_out_dir" ]; then
    rm -rf $dtb_out_dir
fi

mkdir -p $dtb_out_dir

shift 2

for dts_file in $@
do
	dtb_file=${dts_file%.dts}.dtb
	dtb_file=${dtb_file##*/}
	dtc -I dts -O dtb $dts_src_dir/$dts_file -o $dtb_out_dir/$dtb_file || { echo >&2 compile dtb file failed; exit 1; }
done
