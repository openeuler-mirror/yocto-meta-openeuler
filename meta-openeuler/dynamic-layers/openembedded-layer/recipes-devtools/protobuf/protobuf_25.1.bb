SUMMARY = "Protocol Buffers - structured data serialisation mechanism"
DESCRIPTION = "Protocol Buffers are a way of encoding structured data in an \
efficient yet extensible format. Google uses Protocol Buffers for almost \
all of its internal RPC protocols and file formats."
HOMEPAGE = "https://github.com/google/protobuf"
SECTION = "devel"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=37b5762e07f0af8c74ce80a8bda4266b"

# protobuf 25.1 from src-openeuler (cmake build system)
SRC_URI = "file://protobuf-all-${PV}.tar.gz \
           file://0001-add-secure-compile-option.patch \
           file://0002-Fix-CC-compiler-support.patch \
           file://0003-protobuf-add-coverage-compile-option.patch \
           file://0004-backport-CVE-2024-7254-1.patch \
           file://0005-backport-CVE-2024-7254-2.patch \
           file://0006-fix-CVE-2025-4565-1.patch \
           file://0007-fix-CVE-2025-4565-2.patch \
           file://0008-fix-CVE-2026-0994-Fix-Any-recursion-depth-bypass-in-Python.patch \
           "

S = "${WORKDIR}/protobuf-${PV}"

DEPENDS = "zlib abseil-cpp"
DEPENDS:append:class-target = " protobuf-native"

inherit cmake pkgconfig


EXTRA_OECMAKE = " \
    -Dprotobuf_BUILD_TESTS=OFF \
    -Dprotobuf_BUILD_SHARED_LIBS=ON \
    -Dprotobuf_INSTALL_EXAMPLES=OFF \
    -Dprotobuf_WITH_ZLIB=ON \
    -Dprotobuf_ABSL_PROVIDER=package \
"

FILES:${PN} += "${libdir}/*.so*"
FILES:${PN}-dev += "${includedir} ${libdir}/cmake ${libdir}/pkgconfig"

# grpc's cmake config (protobuf-targets.cmake) resolves the imported
# target protobuf::protoc to ${bindir}/protoc; stage it so dependent
# recipes (grpc, isulad) can resolve the target
SYSROOT_DIRS += "${bindir}"

BBCLASSEXTEND = "native nativesdk"
