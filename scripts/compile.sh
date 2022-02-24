#!/bin/bash

usage()
{
    echo "Tip: . $(basename "${BASH_SOURCE[0]}") <MACHINE> [BUILD_DIR]"
    echo "       Support machine:"
    echo "                       qemu-aarch64"
    echo "                       qemu-arm"
    echo "                       raspberrypi4-64"
}

get_build_info()
{
    MACHINE="$1"
    BUILD_DIR="$2"

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

    SRC_DIR="$(cd $(dirname "${BASH_SOURCE[0]}")/../../;pwd)"
    [[ -z "${BUILD_DIR}" ]] && BUILD_DIR="${SRC_DIR}/build"

    if [[ -z "${MACHINE}" ]];then
        usage
    fi
}

set_env()
{
    export PATH="/opt/buildtools/ninja-1.10.1/bin/:/usr/sbin/:$PATH"

    TEMPLATECONF="${SRC_DIR}/yocto-meta-openeuler/meta-openeuler/conf"
    mkdir -p "${BUILD_DIR}"
    source "${SRC_DIR}"/yocto-poky/oe-init-build-env "${BUILD_DIR}"
    set +x
    sed -i "s|^MACHINE.*|MACHINE = \"${MACHINE}\"|g" conf/local.conf

    echo "$MACHINE" | grep -q "^raspberrypi"
    if [ $? -eq 0 ];then
        grep "meta-raspberrypi" conf/bblayers.conf |grep -qv "^[[:space:]]*#" || sed -i "/\/meta-openeuler /a \  "${SRC_DIR}"/yocto-meta-openeuler/bsp/meta-raspberrypi \\\\" conf/bblayers.conf
    fi

    AUTOMAKE_V=$(ls /usr/bin/automake-1.* |awk -F "/" '{print $4}')
    grep -q "HOSTTOOLS .*$AUTOMAKE_V" conf/local.conf || echo "HOSTTOOLS += \"$AUTOMAKE_V\"" >> conf/local.conf
}

main()
{
    get_build_info $@
    set_env
    echo -e "Tip: You can now run 'bitbake openeuler-image'.\n"
}

main $@
