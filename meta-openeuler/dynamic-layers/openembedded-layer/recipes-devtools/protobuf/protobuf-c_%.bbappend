# main bbfile: yocto-meta-openembedded/meta-oe/recipes-devtools/protobuf/protobuf-c_1.4.1.bb


# version in openEuler
PV = "1.4.1"
S = "${WORKDIR}/${BP}"

# files, patches that come from openeuler
SRC_URI:prepend = " \
    file://v${PV}.tar.gz \
    file://backport-Update-autotools.patch \
    file://backport-configure.ac-Require-C-17.patch \
    file://backport-protoc-c-Remove-GOOGLE_DISALLOW_EVIL_CONSTRUCTORS-ma.patch \
    file://backport-protoc-c-Use-FileDescriptorLegacy-to-obtain-proto-sy.patch \
    file://backport-configure.ac-Remove-proto3_supported-BUILD_PROTO3.patch \
    file://backport-Makefile.am-Remove-conditional-BUILD_PROTO3-rules.patch \
    file://backport-protoc-c-c_file.cc-Remove-HAVE_PROTO3-conditional.patch \
    file://backport-protoc-c-c_helpers.h-Remove-HAVE_PROTO3-conditional.patch \
    file://backport-cmake-Remove-BUILD_PROTO3-HAVE_PROTO3.patch \
    file://backport-configure.ac-Drop-Wc99-c11-compat.patch \
    file://backport-Work-around-GOOGLE_-changes-in-protobuf-22.0.patch \
    file://backport-Use-GOOGLE_LOG-FATAL-instead-of-GOOGLE_LOG-DFATAL.patch \
"

