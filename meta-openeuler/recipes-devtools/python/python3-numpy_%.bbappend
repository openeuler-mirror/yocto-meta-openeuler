PV = "1.21.4"

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=b076ad374a7d311ba3126a22b2d52596"
SRC_URI[md5sum] = "b3c4477a027d5b6fba5e1065064fd076"
SRC_URI[sha256sum] = "e6c76a87633aa3fa16614b61ccedfae45b91df2767cf097aa9c933932a7ed1e0"
OPENEULER_REPO_NAME = "numpy"

SRC_URI:prepend = "file://numpy-${PV}.zip "
S = "${WORKDIR}/numpy-${PV}"

# remove poky conflict src
SRC_URI:remove = " \
        https://github.com/${SRCNAME}/${SRCNAME}/releases/download/v${PV}/${SRCNAME}-${PV}.tar.gz \
        file://CVE-2021-41496.patch \
        "
# apply new patch for new version, see:
# http://cgit.openembedded.org/openembedded-core/tree/meta/recipes-devtools/python/python3-numpy_1.23.4.bb
SRC_URI:append = "file://0001-generate_umath.py-do-not-write-full-path-to-output-f.patch "

#apply openeuler patch
SRC_URI:append = " \
        file://backport-CVE-2021-41496.patch \
        file://backport-CVE-2021-41495.patch \
        file://backport-CVE-2021-34141.patch \
        "

# It's a workaround:
# Due to updates to the compiler and C library, we have found that some for loops 
#   have been optimized with logical issues, resulting in segmentation faults. 
# Therefore, we are implementing a contingency plan by changing the default 
#   optimization configuration from O2 to O1
CXXFLAGS:prepend:class-target = " -O1 "
CFLAGS:prepend:class-target = " -O1 "
CXXFLAGS:remove:class-target = "-O2"
CFLAGS:remove:class-target = "-O2"
