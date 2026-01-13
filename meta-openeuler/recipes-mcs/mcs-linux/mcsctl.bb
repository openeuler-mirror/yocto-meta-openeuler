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

    # install rtos bin for xen
    set -- "${S}/rtos/arm64/${RTOS_IMGS}"*.bin
    if [ -f "$1" ]; then
        install -d "${D}/lib/firmware"
        cp -- "$@" "${D}/lib/firmware/"
    fi
}

FILES:${PN} += "/usr/bin/mica"
FILES:${PN} += "/lib/firmware"
FILES:${PN} += "/etc/mica"
INSANE_SKIP:${PN} += "already-stripped"

# Deploy uniproton images to DEPLOY_DIR_IMAGE for micrun to use
inherit deploy
do_deploy() {
    # Deploy uniproton elf and bin files for micrun
    for uniproton_elf in "${S}/rtos/arm64/${RTOS_IMGS}"*uniproton*.elf; do
        if [ -f "$uniproton_elf" ]; then
            basename=$(basename "$uniproton_elf")
            install -d "${DEPLOY_DIR_IMAGE}"
            install -m 0644 "$uniproton_elf" "${DEPLOY_DIR_IMAGE}/${basename}"
            # Also create a symlink with simpler name for mcs-oci-utils.bbclass to find
            ln -sf "${basename}" "${DEPLOY_DIR_IMAGE}/uniproton.elf"
        fi
    done

    for uniproton_bin in "${S}/rtos/arm64/${RTOS_IMGS}"*uniproton*.bin; do
        if [ -f "$uniproton_bin" ]; then
            basename=$(basename "$uniproton_bin")
            install -d "${DEPLOY_DIR_IMAGE}"
            install -m 0644 "$uniproton_bin" "${DEPLOY_DIR_IMAGE}/${basename}"
            # Also create a symlink with simpler name for mcs-oci-utils.bbclass to find
            ln -sf "${basename}" "${DEPLOY_DIR_IMAGE}/uniproton.bin"
        fi
    done
}
addtask deploy after do_install before do_build
