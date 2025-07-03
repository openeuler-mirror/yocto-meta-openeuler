SUMMARY = "H.265/HEVC video encoder"
DESCRIPTION = "A free software library and application for encoding video streams into the H.265/HEVC format."
HOMEPAGE = "http://www.videolan.org/developers/x265.html"

LICENSE = "GPL-2.0-only"
LICENSE_FLAGS = "commercial"
LIC_FILES_CHKSUM = "file://COPYING;md5=c9e0427bc58f129f99728c62d4ad4091"

DEPENDS = "nasm-native gnutls zlib libpcre numactl"

inherit lib_package pkgconfig cmake

# source from openeuler 
SRC_URI = "file://x265_3.5.tar.gz \
        file://x265-3.5-port-to-newer-cmake.patch \
        "

S = "${WORKDIR}/x265_3.5"
B = "${WORKDIR}/build"

# ref x265.spec from src-openeuler
EXTRA_OECMAKE:append:aarch64 = " \
    -S ${S}/source -B ${B} \
    -DCMAKE_INSTALL_PREFIX=${prefix} \
    -DLIB_INSTALL_DIR=${libdir} \
    -DINCLUDE_INSTALL_DIR=${includedir} \
    -DBIN_INSTALL_DIR=${bindir} \
    -DCHECKED_BUILD=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DENABLE_ASSEMBLY=ON \
    -DENABLE_CLI=ON \
    -DENABLE_HDR10_PLUS=OFF \
    -DENABLE_LIBNUMA=ON \
    -DENABLE_LIBVMAF=OFF \
    -DENABLE_PIC=OFF \
    -DENABLE_PPA=OFF \
    -DENABLE_SHARED=ON \
    -DENABLE_SVT_HEVC=OFF \
    -DENABLE_TESTS=OFF \
    -DENABLE_VTUNE=OFF \
    -DNO_ATOMICS=OFF \
    -DSTATIC_LINK_CRT=OFF \
    -DWARNINGS_AS_ERRORS=OFF \
"

