SUMMARY = "ARM Trusted Firmware for hi3093"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://licenses/LICENSE.MIT;md5=57d76440fc5c9183c79d1747d18d2410"

inherit kernel-arch

FILESEXTRAPATHS:append := "${THISDIR}/files/:"

SRC_URI = " \
    file://mpu_solution/open_source/arm-trusted-firmware-2.7 \
    file://fix-undefined-reference-to-pthread.patch \
"

S = "${WORKDIR}/mpu_solution/open_source/arm-trusted-firmware-2.7"

export CFLAGS=" -O2 -pipe -g -feliminate-unused-debug-types "
export CXXFLAGS=" -O2 -pipe -g -feliminate-unused-debug-types "
export LDFLAGS=" --no-warn-rwx-segments -Wl,-O1 -Wl,--hash-style=gnu -Wl,--as-needed -Wl,--build-id=sha1 -Wl,-z,noexecstack -Wl,-z,relro,-z,now"
export CPPFLAGS=""

do_configure:prepend() {
    # ref mpu_solution/build/build_atf/build_atf.sh: cp $ATF_PRIV_PATH/* $ATF_VER_PATH/ -rf
    cp -rf ${S}/plat/hisilicon/hibmc/* ${S}/

    # ref mpu_solution/build/build_atf/build_atf.sh: 
    LINE_194_CONTENT=`cat Makefile | sed -n '194p'`
    sed -i '195i LDFLAGS:=--no-warn-rwx-segments' Makefile

    # fix pedantic error:
    sed -i 's#-Wall -Werror -pedantic##g' tools/fiptool/Makefile
}

EXTRA_OEMAKE="CROSS_COMPILE=${TARGET_PREFIX}"

do_compile:append() {
    oe_runmake VERSION_MAJOR=013 VERSION_MINOR= VERSION_SVN=69275 DEBUG=0 UMPTE_BOARD=0 CHIP_VERIFY_BOARD=0 FVP_TSP_RAM_LOCATION=tdram FVP_SHARED_DATA_LOCATION=tdram PLAT=Hi1711 ARCH=aarch64 CROSS_COMPILE=${TARGET_PREFIX} TFCFG_COMPILE_PRODUCT=Hi1711 bl31 fip
}

do_install:append() {
    install -d ${D}/boot/
    install ${B}/build/Hi1711/release/bl31.bin ${D}/boot/
    install ${B}/build/Hi1711/release/bl31/bl31.dump ${D}/boot/
    install ${B}/build/Hi1711/release/bl31/bl31.map ${D}/boot/
}

# export /boot dir for u-boot pack
SYSROOT_DIRS += "/boot"
SYSROOT_PREPROCESS_FUNCS += "additional_populate_sysroot" 
additional_populate_sysroot() {                           
    sysroot_stage_dir ${D}/boot ${SYSROOT_DESTDIR}/boot
}                                                         

FILES:${PN} += "/boot/*"

