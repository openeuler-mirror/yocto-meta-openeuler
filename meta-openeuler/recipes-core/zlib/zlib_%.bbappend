#main bbfile: yocto-poky/meta/recipes-core/zlib/zlib_1.2.11.bb

#version in openEuler
PV = "1.3.1"

# files, patches that come from openeuler
SRC_URI = " \
        file://${BP}.tar.xz \
        file://backport-zlib-1.2.5-minizip-fixuncrypt.patch \
        file://backport-fix-undefined-buffer-detected-by-oss-fuzz.patch \
        "

# files, patches that come from openeuler for aarch64, there are compile err in 0004-zlib-Optimize-CRC32.patch, not apply
SRC_URI:append:aarch64 = " \
        file://zlib-1.2.11-SIMD.patch \
        "

SRC_URI[md5sum] = "5e6af153311327e516690d300527ec9e"
SRC_URI[sha256sum] = "38ef96b8dfe510d42707d9c781877914792541133e1870841463bfa73f883e32"

B = "${WORKDIR}/build"

do_configure() {
	LDCONFIG=true ${S}/configure --prefix=${prefix} --shared --libdir=${libdir} --uname=GNU
}
do_configure[cleandirs] += "${B}"
