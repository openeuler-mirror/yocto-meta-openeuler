# main bb: yocto-meta-openembedded/meta-oe/recipes-devtools/grpc/grpc_1.36.4.bb
PV = "1.41.1"

S = "${WORKDIR}/${BP}"

LIC_FILES_CHKSUM = "file://LICENSE;md5=3b83ef96387f14655fc854ddc3c6bd57"

OPENEULER_SRC_URI_REMOVE = "https http git gitsm"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

# Libdir not match, do not apply repair-pkgconfig-path.patch
SRC_URI = " \
        file://${BPN}-${PV}.tar.gz \
        file://repair-pkgconfig-path.patch \
        file://add-secure-compile-option-in-Makefile.patch \
        file://backport-grpc-1.41.1-python-grpcio-use-system-abseil.patch \
        file://backport-Ignore-Connection-Aborted-errors-on-accept-29318.patch \
        file://backport-iomgr-EventEngine-Improve-server-handling-o.patch \
        file://fix-CVE-2023-33953-add-header-limit.patch \
        file://remove-cert-expired-on-20230930.patch \
"
# from high version recipe diffs
EXTRA_OECMAKE += " \
        -D_gRPC_PROTOBUF_PROTOC_EXECUTABLE=${STAGING_BINDIR_NATIVE}/protoc \
"

# avoid downloading
do_configure_prepend () {
    mkdir -p ${S}/third_party/opencensus-proto/src
}

FILES_${PN}-dev += "/usr/lib/pkgconfig/*"