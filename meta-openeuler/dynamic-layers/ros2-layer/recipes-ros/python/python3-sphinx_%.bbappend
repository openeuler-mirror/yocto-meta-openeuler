#main bbfile: yocto-meta-ros/meta-ros-common/recipes-devtools/python/python3-sphinx_1.6.7.bb
#yocto-poky(4.0.x) has a sphinx recipe in meta/recipes-devtools/python/python3-sphinx_4.4.0.bb
# the one in meta-ros-common will override the one in yocto-poky as meta-ros-common has higher
# layer priority
PV = "7.0.1"
LIC_FILES_CHKSUM = "file://LICENSE;md5=5eb6ac1b115a1ed24a12d9f15b633993"
LICENSE = "BSD-2-Clause & MIT & BSD-3-Clause"
SRC_URI[md5sum] = "663e2f2ee9219ef4913831950825f68b"
SRC_URI[sha256sum] = "61e025f788c5977d9412587e733733a289e2b9fdc2fef8868ddfbfc4ccfe881d"

# the src repo stores the pypi sdist with its canonical casing
PYPI_PACKAGE = "Sphinx"
SRC_URI:prepend = "file://${PYPI_PACKAGE}-${PV}.tar.gz "
