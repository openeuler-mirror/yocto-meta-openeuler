# main bbfile: yocto-poky/meta/recipes-multimedia/x264/x264_git.bb

PV = "0.164"

DEPENDS += "gnu-config-native"

# source change to openEuler
SRC_URI = "file://x264-0.164-20231001git31e19f92.tar.bz2 \
        file://x264-nover.patch \
        file://x264-10b.patch \
        file://x264-opencl.patch \
        file://version.h \
        "                             

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

S = "${WORKDIR}/x264-0.164-20231001git31e19f92"

# 31e19f92f00c7003fa115047ce50978bc98c3a0d not need
# ref 31e19f92f00c7003fa115047ce50978bc98c3a0d from openembedded-core recipes
X264_DISABLE_ASM:remove = " \
         --extra-cflags="${TUNE_CCARGS}" \
"

# ref 31e19f92f00c7003fa115047ce50978bc98c3a0d from openembedded-core recipes
COMPATIBLE_HOST:x86-x32 = "null"

do_configure:append() {
    cat ${WORKDIR}/version.h >> ${S}/x264_config.h
}
