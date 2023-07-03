# main bbfile: yocto-meta-openembedded/meta-oe/recipes-devtools/protobuf/protobuf_3.15.2.bb

OPENEULER_SRC_URI_REMOVE = "https git"
OPENEULER_REPO_NAME = "protobuf"
OPENEULER_BRANCH = "master"

# version in openEuler
PV = "3.14.0"
S = "${WORKDIR}/protobuf-${PV}"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI:remove = " \
        file://0001-Lower-init-prio-for-extension-attributes.patch \
"
# files, patches that come from openeuler
SRC_URI:prepend = " \
    file://protobuf-all-${PV}.tar.gz \
    file://0001-add-secure-compile-option-in-Makefile.patch \
    file://0002-add-secure-compile-fs-check-in-Makefile.patch \
    file://0003-fix-CVE-2021-22570.patch \
    file://0004-Improve-performance-of-parsing-unknown-fields-in-Jav.patch \
    file://0005-fix-CVE-2022-1941.patch \
    file://0006-fix-CVE-2022-3171.patch \
"

SRC_URI[md5sum] = "d0a7dd930210af5285c08c8a2c2304ab"
SRC_URI[sha256sum] = "6dd0f6b20094910fbb7f1f7908688df01af2d4f6c5c21331b9f636048674aebf"

