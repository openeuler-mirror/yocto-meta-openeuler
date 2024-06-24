# main bbfile: meta-ros/meta-ros-common/recipes-infrastructure/python/python3-catkin-pkg_0.4.24.bb

PV = "0.5.2"

LICESNSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=f223d8c5dc6d4bd04ad8bf355633bfc8"

S = "${WORKDIR}/catkin_pkg-${PV}"

SRC_URI:prepend = " file://${PV}.tar.gz "

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI:remove = " \
        file://0001-python_setup.py-fix-build-with-setuptools-v59.0.0-an.patch \
        "
