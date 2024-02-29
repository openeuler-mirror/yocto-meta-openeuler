#!/bin/bash

function delete_dir() {
	while [ $# != 0 ] ; do
		[ -n "$1" ] && rm -rf ./$1 ; shift; done
}

function do_patch() {
	pushd $1
	if [ $1 = "isl" ];then
		tar xf $1-0.24.tar.gz
	elif [ $1 = "zlib" ];then
		tar xf *.tar.*
	else
		PKG=$(echo *.tar.*)
        echo "$1: do_unpack for of $PKG..."
		tar xf *.tar.*
        echo "make patchlist of $1..."
		cat *.spec | grep "Patch" | grep -v "#" |grep "\.patch" | awk -F ":" '{print $2}' > $1-patchlist
        ls ${OE_PATCH_DIR}/ | grep "^$1" > $1-patchlist-oe || true
		pushd ${PKG%%.tar.*}
		for i in `cat ../$1-patchlist`
		do
            echo "----------------apply patch $i:"
			patch -p1 < ../$i
		done
		for i in `cat ../$1-patchlist-oe`
		do
            echo "----------------apply patch ${OE_PATCH_DIR}/$i:"
			patch -p1 < ${OE_PATCH_DIR}/$i
		done
		popd
	fi
	popd
    echo "------------do_patch for $1 done!"
}

function download_and_patch() {
	while [ $# != 0 ] ; do
		[ -n "$1" ] && echo "Download $1" && git clone -b $COMMON_BRANCH https://gitee.com/src-openeuler/$1.git --depth 1 && do_patch $1; shift;
	done
}

function do_prepare() {
	[ ! -d "$LIB_PATH" ] && mkdir $LIB_PATH
	pushd $LIB_PATH
	delete_dir $KERNEL $GCC $GLIBC $MUSLC $BINUTILS $GMP $MPC $MPFR $ISL $EXPAT $GETTEXT $NCURSES $ZLIB $LIBICONV $GDB
	git clone -b $KERNEL_BRANCH https://gitee.com/openeuler/kernel.git --depth 1
	git clone -b $MUSLC_BRANCH https://gitee.com/src-openeuler/musl.git --depth 1 && do_patch musl;
	download_and_patch $GCC $GLIBC $BINUTILS $GMP $MPC $MPFR $ISL $EXPAT $NCURSES $ZLIB $GDB
	#LIBICONV and GETTEXT dir is need, but with no code, it will skip when ct-ng build under our openeuler env.
	mkdir -p $LIB_PATH/$LIBICONV/$LIBICONV_DIR
	mkdir -p $LIB_PATH/$GETTEXT/$GETTEXT_DIR
	popd
}

usage()
{
	echo -e "Tip: sh "$THIS_SCRIPT" <work_dir>\n"
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
    OE_PATCH_DIR="$SRC_DIR/patches"
	readonly LIB_PATH="$WORK_DIR/open_source"

	do_prepare

	cd $WORK_DIR
	echo "Prepare done! Now you can run: (not in root please)"
	echo "'cp config_arm32 .config && ct-ng build' for build arm"
	echo "'cp config_aarch64 .config && ct-ng build' for build arm64"
	echo "'cp config_x86_64 .config && ct-ng build' for build x86_64"
	echo "'cp config_riscv64 .config && ct-ng build' for build riscv64"
	echo "'cp config_aarch64-musl .config && ct-ng build' for build muslc_aarch64"
}

main "$@"
