# main bbfile: yocto-poky/meta/recipes-support/libjitterentropy_3.4.0.bb

OPENEULER_REPO_NAME = "jitterentropy-library"

# version in openEuler
PV = "3.3.1"

# poky's recipe use git protocol and no patches in SRC_URI, so overwrite directly.
SRC_URI:prepend = "file://jitterentropy-library-${PV}.tar.gz \
           file://jitterentropy-rh-makefile.patch;striplevel=0 \
"

# license file checksum changed.
LIC_FILES_CHKSUM = "file://LICENSE;md5=1c94a9d191202a5552f381a023551396 \
                    file://LICENSE.gplv2;md5=eb723b61539feef013de476e68b5c50a \
                    file://LICENSE.bsd;md5=66a5cedaf62c4b2637025f049f9b826f \
                    "

S = "${WORKDIR}/jitterentropy-library-${PV}"
