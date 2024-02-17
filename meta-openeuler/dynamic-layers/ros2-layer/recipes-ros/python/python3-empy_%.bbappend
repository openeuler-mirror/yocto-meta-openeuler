# main bbfile: yocto-meta-ros/meta-ros-common/recipes-devtools/python/python3-empy_3.3.2.bb

PV = "3.3.4"

LIC_FILES_CHKSUM = "file://README;md5=10d1c4f6d15ab0aa52e80cc7d6ca0959"

SRC_URI[md5sum] = "8bae96e87128393448c1ec837ae78c85"
SRC_URI[sha256sum] = "9126211471fc7ff83fdd40beca93eb6de5681758fbe68b4cf8af6326259df1b1"

S = "${WORKDIR}/empy-${PV}"

SRC_URI:prepend = " file://empy-${PV}.tar.gz "
