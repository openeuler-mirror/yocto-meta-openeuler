#!/bin/bash
# this script is used to setup the yocto build envrionment of openEuler Embedded

usage()
{
    echo "Tip: . $(basename "${BASH_SOURCE[0]}") <PLATFORM> [BUILD_DIR] [TOOLCHAIN_DIR]"
    echo "       Supportted PLATFORM:"
    echo "                       aarch64-std (default)"
    echo "                       aarch64-pro"
    echo "                       arm-std"
    echo "                       raspberrypi4-64"
    echo "       Build dir: <above dir of yocto-meta-openeuler >/build (defaut)"
    echo "       External toolchain dir(absoulte path):"
    echo "                       /usr1/openeuler/gcc/openeuler_gcc_arm64le (default)"
    return 1
}

get_build_info()
{
    PLATFORM="$1"
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
            return 1
        fi
    fi

    if [ -z "$ZSH_NAME" ] && [ "$0" = "$THIS_SCRIPT" ]; then
        echo "Error: This script needs to be sourced. Please run as '. $THIS_SCRIPT'" >&2
        usage || return 1
    fi

    # show help message if no arguments
    if [ $# -eq 0 ]; then
        usage || return 1
    fi

    # get the src dir which contains all src code packages, include yocto repos, linux kernel
    # busybox etc..
    SRC_DIR="$(cd $(dirname "${BASH_SOURCE[0]}")/../../;pwd)"
    [[ -z "${BUILD_DIR}" ]] && BUILD_DIR="${SRC_DIR}/build"

    # set MACHINE and bitbake option
    BITBAKE_OPT="openeuler-image"
    case $PLATFORM in
    "raspberrypi4-64")
        MACHINE="raspberrypi4-64"
        ;;
    "aarch64-std")
        MACHINE="qemu-aarch64"
        BITBAKE_OPT="openeuler-image openeuler-image-tiny"
        ;;
    "aarch64-pro")
        MACHINE="qemu-aarch64"
        ;;
    "arm-std")
        MACHINE="qemu-arm"
        ;;
    *)
        echo "unknown platform, use aarch64-std as default"
        PLATFORM="aarch64-std"
        MACHINE="qemu-aarch64"
    esac

    # set toolchain path
    case $MACHINE in
    "qemu-aarch64" | "raspberrypi4-64")
        OPENEULER_TOOLCHAIN_DIR="OPENEULER_TOOLCHAIN_DIR_aarch64";;
    "qemu-arm")
        OPENEULER_TOOLCHAIN_DIR="OPENEULER_TOOLCHAIN_DIR_arm";;
    *)
        echo "unknown machine"
        usage || return 1
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
    sed -i "s|^MACHINE .*|MACHINE = \"${MACHINE}\"|g" conf/local.conf
    sed -i "s|^OPENEULER_PLATFORM .*|OPENEULER_PLATFORM = \"${PLATFORM}\"|g" conf/local.conf

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
    # if automake-1.* is not in HOSTOOLS, append it
    local automake_v=$(ls /usr/bin/automake-1.* |awk -F "/" '{print $4}')
    grep -q "HOSTTOOLS .*$automake_v" conf/local.conf || echo "HOSTTOOLS += \"$automake_v\"" >> conf/local.conf

    # set DATETIME in conf/local.conf
    # you can set DATETIME from environment variable or get time by date
    # not reset DATETIME when rebuilt in the same directory
    if [[ -z "${DATETIME}" ]];then
        DATETIME="$(date +%Y%m%d%H%M%S)"
    fi
    grep -q "DATETIME" conf/local.conf || echo "DATETIME = \"${DATETIME}\"" >> conf/local.conf
}

main()
{
    get_build_info "$@" || return 1
    set_env
    echo -e "Tip: You can now run 'bitbake ${BITBAKE_OPT}'.\n"
}

do_dsoftbus_compile()
{
    rm -rf ${SRC_DIR}/dsoftbus_build/out
    cd ${SRC_DIR}/dsoftbus_build
    ./build.sh --product-name openEuler
}

do_dsoftbus_package()
{
    rm -rf ${SRC_DIR}/dsoftbus_output
    mkdir ${SRC_DIR}/dsoftbus_output
    install -d ${SRC_DIR}/dsoftbus_output/usr/include/
    install -d ${SRC_DIR}/dsoftbus_output/usr/lib64/
    install -d ${SRC_DIR}/dsoftbus_output/usr/bin
    cp ${SRC_DIR}/dsoftbus_build/out/ohos-arm64-release/common/common/*.so ${SRC_DIR}/dsoftbus_output/usr/lib64/
    cp ${SRC_DIR}/dsoftbus_build/out/ohos-arm64-release/communication/dsoftbus_standard/*.so ${SRC_DIR}/dsoftbus_output/usr/lib64/
    cp ${SRC_DIR}/dsoftbus_build/out/ohos-arm64-release/communication/dsoftbus_standard/softbus_server_main ${SRC_DIR}/dsoftbus_output/usr/bin
    cp -r ${SRC_DIR}/dsoftbus_build/foundation/communication/dsoftbus/interfaces/kits/ ${SRC_DIR}/dsoftbus_output/usr/include/
}

if [ "$1" == "dsoftbus" ];then
    SRC_DIR=$2
    if [ -z "${SRC_DIR}" ];then
        SRC_DIR="$(cd $(dirname $0)/../../;pwd)"
    fi

    do_dsoftbus_compile
    do_dsoftbus_package
else
    main "$@"
fi
