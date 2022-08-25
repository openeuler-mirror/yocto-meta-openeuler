#!/bin/bash
# this script is used to setup the yocto build envrionment of openEuler Embedded

script=`basename "${BASH_SOURCE[0]}"`
script_dir=$(realpath $(dirname "${BASH_SOURCE[0]}"))

usage () {
cat << EOF
Usage: 
download mode: source $script [-D] [-d DOWNLOAD_DIR] <-b BRANCH> <-m MANIFEST_FILE>
compile mode: source $script [-C] [-p PLATFORM] [-o BUILD_DIR] <-t TOOLCHAIN_DIR>  <-i INIT_MANAGER> <--enable-rt>
  [] -- need   <> -- Optional
-------------------------------------------------------
  -h                show this help and exit.
  -D                download mode:
  -d DOWNLOAD_DIR   [top/directory/to/put/your/code]
  -b BRANCH         [branch]
  -m MANIFEST_FILE  <manifest file path>
  -C                compile mode:
  -p PLATFORM       Supportted PLATFORM
                         aarch64-std
                         aarch64-pro
                         arm-std
                         x86-64-std
                         raspberrypi4-64
                         riscv64-std
  -o BUILD_DIR      Build dir: 
                    <above dir of yocto-meta-openeuler >/build (defaut)
  -t TOOLCHAIN_DIR  External toolchain dir(absoulte path):
                        /usr1/openeuler/gcc/openeuler_gcc_arm64le (arm64 default)
                        /usr1/openeuler/gcc/openeuler_gcc_arm32le (arm32 default)
                        /usr1/openeuler/gcc/openeuler_gcc_x86_64 (x86_64 default)
  -i INIT_MANAGER   INIT_MANAGER suooprt:
                        busybox (defaut)
                        systemd
  --enable-rt       Enable PREEMPT_RT kernel
EOF
}                                                                            


check_cmd_source () {
    if [ -n "$BASH_SOURCE" ]; then
        THIS_SCRIPT="$BASH_SOURCE"
    elif [ -n "$ZSH_NAME" ]; then
        THIS_SCRIPT="$0"
    else
        THIS_SCRIPT="$(pwd)/oe_helper.sh"
        if [ ! -e "$THIS_SCRIPT" ]; then
            echo "Error: $THIS_SCRIPT doesn't exist!"
            return 1
        fi
    fi

    if [ -z "$ZSH_NAME" ] && [ "$0" = "$THIS_SCRIPT" ]; then
        echo "Error: This script needs to be sourced. Please run as '. $THIS_SCRIPT'" >&2
        usage
        return 1
    fi
}

check_cmd_source || exit 1
compile_mode=0
download_mode=0
ENABLE_PREEMPT_RT=0
INIT_MANAGER="busybox"
OPTIND=1

while getopts "hDCSd:b:m:p:o:t:i:-:" opt; do
    case $opt in
        -)
            case "${OPTARG}" in
                enable-rt) ENABLE_PREEMPT_RT=1
                           echo "Note: enable PREEMPT_RT."
                           ;;
                *)  usage
                    return 1
                    ;;
            esac
            ;;
        h)  usage
            return 0
            ;;
        D)  download_mode=1
            echo download_mode
            ;;
        C)  compile_mode=1
            echo compile_mode
            ;;
        d)  DOWNLOAD_DIR=$OPTARG
            ;;
        b)  BRANCH=$OPTARG
            ;;
        m)  MANIFEST_FILE=$OPTARG
            ;;
        p)  PLATFORM=$OPTARG
            ;;
        o)  BUILD_DIR=$OPTARG
            ;;
        t)  TOOLCHAIN_DIR=$OPTARG
            ;;
        i)  INIT_MANAGER=$OPTARG
            ;;
        *)  usage
            return 1
            ;;
    esac
done

if [ $download_mode == 0 ] && [ $compile_mode == 0 ]; then
    echo "Invalid input."
    usage
    return 1
fi

if [ $download_mode == 1 ]; then
    if [ -z ${DOWNLOAD_DIR} ]; then
        echo "Invalid input of DOWNLOAD_DIR."
        usage
        return 1
    fi
    sh ${script_dir}/download_code.sh ${DOWNLOAD_DIR} ${BRANCH} ${MANIFEST_FILE}
    return 0
fi

if [ $compile_mode == 1 ]; then
    if [ -z ${PLATFORM} ] || [ -z ${BUILD_DIR} ]; then
        echo "Invalid input of PLATFORM or BUILD_DIR."
        usage
        return 1
    fi
    if [ "$INIT_MANAGER" != "busybox" ] && [ "$INIT_MANAGER" != "systemd" ]; then
        echo Invalid INIT_MANAGER input.
        usage
        return 1
    fi
    source ${script_dir}/compile.sh ${PLATFORM} ${BUILD_DIR} ${TOOLCHAIN_DIR}
    if [ $ENABLE_PREEMPT_RT == 1 ]; then
        sed -i "s|^PREFERRED_PROVIDER_virtual/kernel .*|PREFERRED_PROVIDER_virtual/kernel = \"linux-openeuler-rt\"|g" conf/local.conf
    fi
    case $INIT_MANAGER in
    "busybox")
        sed -i "s|^OPENEULER_INIT_MANAGER .*|OPENEULER_INIT_MANAGER = \"mdev-busybox\"|g" conf/local.conf
        sed -i "s|^OPENEULER_DEV_MANAGER .*|OPENEULER_DEV_MANAGER = \"busybox-mdev\"|g" conf/local.conf
        ;;
    "systemd")
        sed -i "s|^OPENEULER_INIT_MANAGER .*|OPENEULER_INIT_MANAGER = \"systemd\"|g" conf/local.conf
        sed -i "s|^OPENEULER_DEV_MANAGER .*|OPENEULER_DEV_MANAGER = \"systemd\"|g" conf/local.conf
        ;;
    *)
    esac
    return 0
fi

