# main bbfile: yocto-meta-openembedded/meta-oe/recipes-support/libeigen/libeigen_3.3.7.bb

OPENEULER_SRC_URI_REMOVE = "https git"
OPENEULER_REPO_NAME = "eigen"
OPENEULER_BRANCH = "master"

# version in openEuler
PV = "3.3.8"
S = "${WORKDIR}/eigen-${PV}"

LIC_FILES_CHKSUM = "file://COPYING.MPL2;md5=815ca599c9df247a0c7f619bab123dad \
                    file://COPYING.BSD;md5=543367b8e11f07d353ef894f71b574a0 \
                    file://COPYING.GPL;md5=d32239bcb673463ab874e80d47fae504 \
                    file://COPYING.LGPL;md5=4fbd65380cdd255951079008b364516c \
                    file://COPYING.MINPACK;md5=5fe4603e80ef7390306f51ef74449bbd \
"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI:remove = " \
    file://0001-Default-eigen_packet_wrapper-constructor.patch \
"
# files, patches that come from openeuler
SRC_URI:prepend = " \
    file://eigen-${PV}.tar.bz2 \
    file://0001-rebuild-and-modify-exception-error.patch \
"
SRC_URI[md5sum] = "432ef01499d514f4606343276afa0ec3"
SRC_URI[sha256sum] = "0215c6593c4ee9f1f7f28238c4e8995584ebf3b556e9dbf933d84feb98d5b9ef"

