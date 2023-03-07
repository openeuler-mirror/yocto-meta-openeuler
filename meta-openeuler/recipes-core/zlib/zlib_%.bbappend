#main bbfile: yocto-poky/meta/recipes-core/zlib/zlib_1.2.11.bb

#version in openEuler
PV = "1.2.13"

OPENEULER_BRANCH = "openEuler-23.03"
OPENEULER_SRC_URI_REMOVE = "https git http"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
        file://CVE-2018-25032.patch \
        file://ldflags-tests.patch \
        "
# files, patches that come from openeuler
SRC_URI += " \
        file://${BP}.tar.xz \
        file://backport-zlib-1.2.5-minizip-fixuncrypt.patch \
        file://backport-fix-undefined-buffer-detected-by-oss-fuzz.patch \
        "

# files, patches that come from openeuler for aarch64, there are compile err in 0004-zlib-Optimize-CRC32.patch, not apply
SRC_URI_append_aarch64 += " \
        file://zlib-1.2.11-SIMD.patch \
        "

SRC_URI[tarball.md5sum] = "85adef240c5f370b308da8c938951a68"
SRC_URI[tarball.sha256sum] = "4ff941449631ace0d4d203e3483be9dbc9da454084111f97ea0a2114e19bf066"
