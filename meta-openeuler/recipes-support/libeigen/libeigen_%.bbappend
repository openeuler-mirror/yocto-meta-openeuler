# main bbfile: yocto-meta-openembedded/meta-oe/recipes-support/libeigen/libeigen_3.3.7.bb

OPENEULER_SRC_URI_REMOVE = "https git"
OPENEULER_REPO_NAME = "eigen"

# version in openEuler
PV = "3.3.8"
S = "${WORKDIR}/eigen-${PV}"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
"
# files, patches that come from openeuler
SRC_URI_prepend = " \
    file://eigen-${PV}.tar.bz2 \
    file://0001-rebuild-and-modify-exception-error.patch \
"
SRC_URI[md5sum] = "432ef01499d514f4606343276afa0ec3"
SRC_URI[sha256sum] = "0215c6593c4ee9f1f7f28238c4e8995584ebf3b556e9dbf933d84feb98d5b9ef"

