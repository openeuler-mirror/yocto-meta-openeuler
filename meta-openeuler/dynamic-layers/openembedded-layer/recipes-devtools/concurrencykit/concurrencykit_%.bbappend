PV = "0.7.1"

LIC_FILES_CHKSUM = "file://LICENSE;md5=a0b24c1a8f9ad516a297d055b0294231"

SRC_URI = "file://${PV}.tar.gz \
"

# patches from meta-oe version "0.7.0+git"
# not support riscv, riscv support in 0.7.2
FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"
SRC_URI += " \
           file://0001-configure-Fix-compoiler-detection-logic-for-cross-co.patch \
"

S = "${WORKDIR}/ck-${PV}"

# from meta-oe
do_configure () {
    export PLATFORM=${PLAT}
    ${S}/configure \
    --prefix=${prefix} \
    --includedir=${includedir} \
    --libdir=${libdir}
}
