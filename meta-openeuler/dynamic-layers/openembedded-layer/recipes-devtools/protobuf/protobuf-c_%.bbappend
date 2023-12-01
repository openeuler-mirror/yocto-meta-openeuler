# main bbfile: yocto-meta-openembedded/meta-oe/recipes-devtools/protobuf/protobuf-c_1.4.1.bb

OPENEULER_SRC_URI_REMOVE = "https git http"

# version in openEuler
PV = "1.4.0"
S = "${WORKDIR}/protobuf-c-${PV}"

# files, patches that come from openeuler
SRC_URI = " \
    file://v${PV}.tar.gz \
    file://backport-0001-Fix-issue-499-unsigned-integer-overflow.patch \
    file://backport-0002-Fix-regression-with-zero-length-messages-introduced-.patch \
    file://backport-0001-Fix-a-clang-analyzer-14-warning-about-a-possible-NUL.patch \
"
