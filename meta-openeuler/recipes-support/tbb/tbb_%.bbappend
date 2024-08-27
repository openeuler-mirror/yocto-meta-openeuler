# current oe's version is too new for ros-foxy
# main bb from:
# http://cgit.openembedded.org/meta-openembedded/tree/meta-oe/recipes-support/tbb?id=11562e889d485118ed377ef0dac17b7e95689281

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# version in openEuler
PV = "2021.11.0"

# files, patches that come from openeuler
SRC_URI = "file://tbb-${PV}.tar.gz \
        file://tbb-2021-Werror.patch \
        file://tbb-2021-strict-aliasing.patch \
        file://bugfix-tbb-fix-__TBB_machine_fetchadd4-was-not-declared-on-.patch \
"

S = "${WORKDIR}/oneTBB-${PV}"
