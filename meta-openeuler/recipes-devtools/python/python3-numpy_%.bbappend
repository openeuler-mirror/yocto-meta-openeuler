PV = "1.24.3"

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI[md5sum] = "b3c4477a027d5b6fba5e1065064fd076"
SRC_URI[sha256sum] = "e6c76a87633aa3fa16614b61ccedfae45b91df2767cf097aa9c933932a7ed1e0"
OPENEULER_REPO_NAME = "numpy"

SRC_URI:prepend = "file://numpy-${PV}.tar.gz "
S = "${WORKDIR}/numpy-${PV}"

# remove poky conflict src
SRC_URI:remove = " \
        file://CVE-2021-41496.patch \
        file://0001-numpy-core-Define-RISCV-32-support.patch \
        "

#apply openeuler patch
SRC_URI:append = " \
        file://adapted-cython3_noexcept.patch \
        "
# apply oe-core patch
SRC_URI += "\
        file://0001-simd.inc.src-Change-NPY_INLINE-to-inline.patch \
"
        
RDEPENDS:${PN}-ptest:append = "${PYTHON_PN}-typing-extensions \ "

# It's a workaround:
# Due to updates to the compiler and C library, we have found that some for loops 
#   have been optimized with logical issues, resulting in segmentation faults. 
# Therefore, we are implementing a contingency plan by changing the default 
#   optimization configuration from O2 to O1
CXXFLAGS:prepend:class-target = " -O1 "
CFLAGS:prepend:class-target = " -O1 "
CXXFLAGS:remove:class-target = "-O2"
CFLAGS:remove:class-target = "-O2"
