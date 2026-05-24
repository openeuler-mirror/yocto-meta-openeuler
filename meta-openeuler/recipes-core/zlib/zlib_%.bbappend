#main bbfile: yocto-poky/meta/recipes-core/zlib/zlib_1.2.11.bb

#version in openEuler
PV = "1.2.13"

# files, patches that come from openeuler (SP4: 1.2.13)
SRC_URI = " \
        file://${BP}.tar.xz \
        file://backport-CVE-2023-45853.patch \
        "

# aarch64 SIMD optimization
SRC_URI:append:aarch64 = " \
        file://zlib-1.2.11-SIMD.patch \
        "

B = "${WORKDIR}/build"

do_configure() {
        LDCONFIG=true ${S}/configure --prefix=${prefix} --shared --libdir=${libdir} --uname=GNU
}
do_configure[cleandirs] += "${B}"

ASSUME_PROVIDE_PKGS = "zlib"
