SUMMARY = "Zephyr toolchain for aarch64"
DESCRIPTION = "Official aarch64 toolchain built using crosstool-ng, distributed by the \
Zephyr project"
COMPATIBLE_HOST = "x86_64.*-linux"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

INHIBIT_DEFAULT_DEPS = "1"

OPENEULER_LOCAL_NAME = "zephyrproject"

PV = "0.17.0"

SDK_NAME = "${BUILD_ARCH}"
SRC_URI = "file://toolchain_${PV}/toolchain_linux-x86_64_aarch64-zephyr-elf.tar.xz"

S = "${WORKDIR}/aarch64-zephyr-elf"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

ZEPHYR_SDK_DIR = "${prefix}"

do_install() {
    install -d ${D}${prefix}
    cp -r ${S}/* ${D}${ZEPHYR_SDK_DIR}
}

SYSROOT_DIRS += "${ZEPHYR_SDK_DIR}"
INHIBIT_SYSROOT_STRIP = "1"
BBCLASSEXTEND = "native"
