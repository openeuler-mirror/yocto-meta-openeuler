#!/bin/bash

function delete_dir() {
	while [ $# != 0 ] ; do
		[ -n "$1" ] && rm -rf ./$1 ; shift; done
}

function do_prepare() {
	[ ! -d "$LIB_PATH" ] && mkdir $LIB_PATH
	pushd $LIB_PATH
	delete_dir $LLVM
	git clone -b $LLVM_BRANCH https://gitee.com/openeuler/$LLVM.git --depth 1
	popd
}

usage()
{
	echo -e "Tip: sh llvm-toolchain/prepare.sh <work_dir>\n"
}

check_use()
{
	if [ -n "$BASH_SOURCE" ]; then
		THIS_SCRIPT="$BASH_SOURCE"
	elif [ -n "$ZSH_NAME" ]; then
		THIS_SCRIPT="$0"
	else
		THIS_SCRIPT="$(pwd)/prepare.sh"
		if [ ! -e "$THIS_SCRIPT" ]; then
			echo "Error: $THIS_SCRIPT doesn't exist!"
			return 1
		fi
	fi

	if [ "$0" != "$THIS_SCRIPT" ]; then
		echo "Error: This script cannot be sourced. Please run as 'sh $THIS_SCRIPT'" >&2
		return 1
	fi
}

main()
{
	usage
	check_use || return 1
	set -e
	WORK_DIR="$1"
	SRC_DIR="$(cd $(dirname $0)/;pwd)"
	SRC_DIR="$(realpath ${SRC_DIR})"
	if [[ -z "${WORK_DIR}" ]];then
		WORK_DIR=$SRC_DIR
		echo "use default work dir: $WORK_DIR"
	fi
	WORK_DIR="$(realpath ${WORK_DIR})"
	source $SRC_DIR/configs/config.xml
	readonly LIB_PATH="$WORK_DIR/open_source"

	do_prepare

	cd $WORK_DIR
	echo "Prepare done! Now you can run: (not in root please)"
	echo "cd $LIB_PATH/$LLVM"
	echo "'./build.sh -e -o -s -i -b release' for LLVM toolchain"
}

main "$@"
