# main bb: yocto-meta-openembedded/meta-oe/recipes-devtools/grpc/grpc_1.46.7.bb
PV = "1.54.2"

S = "${WORKDIR}/${BP}"

LIC_FILES_CHKSUM = "file://LICENSE;md5=731e401b36f8077ae0c134b59be5c906"

OPENEULER_SRC_URI_REMOVE = "https http git gitsm"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI:remove = " \
        file://0001-Revert-Changed-GRPCPP_ABSEIL_SYNC-to-GPR_ABSEIL_SYNC.patch \
        file://0001-cmake-add-separate-export-for-plugin-targets.patch \
"

# Libdir not match, do not apply repair-pkgconfig-path.patch
SRC_URI:prepend = " \
        file://${BPN}-${PV}.tar.gz \
        file://add-secure-compile-option-in-Makefile.patch \
"
# from high version recipe diffs
EXTRA_OECMAKE += " \
        -D_gRPC_PROTOBUF_PROTOC_EXECUTABLE=${STAGING_BINDIR_NATIVE}/protoc \
"

# avoid downloading
do_configure:prepend () {
    mkdir -p ${S}/third_party/opencensus-proto/src
}
