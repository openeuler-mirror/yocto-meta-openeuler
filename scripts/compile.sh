#!/bin/bash
# this script is used to setup the yocto build envrionment of openEuler Embedded

usage()
{
    echo "Tip: . $(basename "${BASH_SOURCE[0]}") <MACHINE> [BUILD_DIR] [TOOLCHAIN_DIR]"
    echo "       Supportted machine:"
    echo "                       qemu-aarch64 (default)"
    echo "                       qemu-arm"
    echo "                       raspberrypi4-64"
    echo "       Build dir: <above dir of yocto-meta-openeuler >/build (defaut)"
    echo "       External toolchain dir(absoulte path):"
    echo "                       /usr1/openeuler/gcc/openeuler_gcc_arm64le (default)"
}

get_build_info()
{
    MACHINE="$1"
    BUILD_DIR="$2"
    TOOLCHAIN_DIR="$3"
    OPENEULER_TOOLCHAIN_DIR="OPENEULER_TOOLCHAIN_DIR_aarch64"

    if [ -n "$BASH_SOURCE" ]; then
        THIS_SCRIPT="$BASH_SOURCE"
    elif [ -n "$ZSH_NAME" ]; then
        THIS_SCRIPT="$0"
    else
        THIS_SCRIPT="$(pwd)/compile.sh"
        if [ ! -e "$THIS_SCRIPT" ]; then
            echo "Error: $THIS_SCRIPT doesn't exist!"
            exit 1
        fi
    fi

    if [ -z "$ZSH_NAME" ] && [ "$0" = "$THIS_SCRIPT" ]; then
        echo "Error: This script needs to be sourced. Please run as '. $THIS_SCRIPT'" >&2
        usage
        exit 1
    fi

# show help message if no arguments
    if [ $# -eq 0 ]; then
        usage
    fi

# get the src dir which contains all src code packages, include yocto repos, linux kernel
# busybox etc..
    SRC_DIR="$(cd $(dirname "${BASH_SOURCE[0]}")/../../;pwd)"
    [[ -z "${BUILD_DIR}" ]] && BUILD_DIR="${SRC_DIR}/build"

    case $MACHINE in
    "qemu-aarch64" | "raspberrypi4-64")
        OPENEULER_TOOLCHAIN_DIR="OPENEULER_TOOLCHAIN_DIR_aarch64";;
    "qemu-arm")
        OPENEULER_TOOLCHAIN_DIR="OPENEULER_TOOLCHAIN_DIR_arm";;
    *)
        echo "unknown machine, use qemu-aarch64 as default"
        MACHINE="qemu-aarch64";;
    esac
}

# this function sets up the yocto build environment
set_env()
{
# as tools like ldconfig will be used, add /usr/sbin in $PATH
    export PATH="/usr/sbin/:$PATH"

# set the TEMPLATECONF of yocto, make build dir and init the yocto build
# environment
    TEMPLATECONF="${SRC_DIR}/yocto-meta-openeuler/meta-openeuler/conf"
    mkdir -p "${BUILD_DIR}"
    source "${SRC_DIR}"/yocto-poky/oe-init-build-env "${BUILD_DIR}"
    set +x

# after oe-init-build-env, will be in ${BUILD_DIR}
# set the MACHINE variable in local.conf through sed cmd
    sed -i "s|^MACHINE.*|MACHINE = \"${MACHINE}\"|g" conf/local.conf

# set the OPENUERL_SP_DIR variable
    sed -i "s|^OPENEULER_SP_DIR .*|OPENEULER_SP_DIR = \"${SRC_DIR}\"|g" conf/local.conf

# set the OPENEULER_TOOLCHAIN_DIR_xxx variable
    if [[ -n ${TOOLCHAIN_DIR} ]];then
        sed -i "s|^${OPENEULER_TOOLCHAIN_DIR}.*|${OPENEULER_TOOLCHAIN_DIR} = \"${TOOLCHAIN_DIR}\"|g" conf/local.conf
    fi

# if raspberrypi is selected, add the layer of meta-raspberry pi
    if echo "$MACHINE" | grep -q "^raspberrypi";then
        grep "meta-raspberrypi" conf/bblayers.conf |grep -qv "^[[:space:]]*#" || sed -i "/\/meta-openeuler /a \  "${SRC_DIR}"/yocto-meta-openeuler/bsp/meta-raspberrypi \\\\" conf/bblayers.conf
    fi
# set the correct automake command and add it into HOSTTOOLS
    AUTOMAKE_V=$(ls /usr/bin/automake-1.* |awk -F "/" '{print $4}')
# if automake-1.* is not in HOSTOOLS, append it
    grep -q "HOSTTOOLS .*$AUTOMAKE_V" conf/local.conf || echo "HOSTTOOLS += \"$AUTOMAKE_V\"" >> conf/local.conf

}

main()
{
    get_build_info $@
    set_env
    echo -e "Tip: You can now run 'bitbake openeuler-image'.\n"
}

main $@
