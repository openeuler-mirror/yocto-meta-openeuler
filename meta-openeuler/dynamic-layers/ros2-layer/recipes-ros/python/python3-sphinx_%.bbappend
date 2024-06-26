#main bbfile: yocto-meta-ros/meta-ros-common/recipes-devtools/python/python3-sphinx_1.6.7.bb
#yocto-poky(4.0.x) has a sphinx recipe in meta/recipes-devtools/python/python3-sphinx_4.4.0.bb
# the one in meta-ros-common will override the one in yocto-poky as meta-ros-common has higher
# layer priority
PV = "4.4.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=de4349dda741c550eb8b20f6b92f38d7"
LICENSE = "BSD-2-Clause & MIT & BSD-3-Clause"
SRC_URI[md5sum] = "663e2f2ee9219ef4913831950825f68b"
SRC_URI[sha256sum] = "6caad9786055cb1fa22b4a365c1775816b876f91966481765d7d50e9f0dd35cc"

SRC_URI:prepend = "file://${PYPI_PACKAGE}-${PV}.tar.gz "
