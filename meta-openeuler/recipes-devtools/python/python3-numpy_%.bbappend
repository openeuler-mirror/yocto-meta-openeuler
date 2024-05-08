# bbfile: yocto-meta-ros/meta-ros-python2/recipes-imported-oe-core-warrior/python/python-numpy_1.16.3.bb
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
        "

#apply openeuler patch
SRC_URI:append = " \
        file://adapted-cython3_noexcept.patch \
        "
