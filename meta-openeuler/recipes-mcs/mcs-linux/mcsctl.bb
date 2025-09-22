### Descriptive metadata: SUMMARY,DESCRITPION, HOMEPAGE, AUTHOR, BUGTRACKER
SUMMARY = "The python tool of openEuler Embedded's MCS feature"
DESCRIPTION = "${SUMMARY}"
AUTHOR = ""
HOMEPAGE = "https://gitee.com/openeuler/mcs"
BUGTRACKER = "https://gitee.com/openeuler/yocto-meta-openeuler"

### License metadata
LICENSE = "MulanPSL-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=74b1b7a7ee537a16390ed514498bf23c"

inherit setuptools3

### Build metadata: SRC_URI, SRCDATA, S, B, FILESEXTRAPATHS....
OPENEULER_LOCAL_NAME = "mcs"

SRC_URI = " \
        file://mcs \
        "
S = "${WORKDIR}/mcs"

SETUPTOOLS_SETUP_PATH = "${S}/mica/micactl"

do_fetch[depends] += "mcs-linux:do_fetch"

RDEPENDS:${PN} = "python3 python3-argcomplete"

RTOS_IMGS:raspberrypi4-64 = "rpi4"
RTOS_IMGS:qemu-aarch64 = "qemu"
RTOS_IMGS:hieulerpi1 = "hieulerpi"

do_install:append () {
    ## todo: more fine-grained process of mica conf file and
    ## RTOS images
    # install Configuration file
    set -- "${S}/rtos/arm64/${RTOS_IMGS}"*.conf
    if [ -f "$1" ]; then
        install -d "${D}/etc/mica"
        cp -- "$@" "${D}/etc/mica/"
    fi


    # install rtos firmware
    set -- "${S}/rtos/arm64/${RTOS_IMGS}"*.elf
    if [ -f "$1" ]; then
        install -d "${D}/lib/firmware"
        cp -- "$@" "${D}/lib/firmware/"
    fi
}

FILES:${PN} += "/usr/bin/mica"
FILES:${PN} += "/lib/firmware"
FILES:${PN} += "/etc/mica"
INSANE_SKIP:${PN} += "already-stripped"
