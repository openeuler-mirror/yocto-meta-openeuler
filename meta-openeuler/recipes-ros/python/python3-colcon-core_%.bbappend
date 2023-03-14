# main bbfile: meta-ros/meta-ros-common/recipes-infrastructure/python/python3-catkin-pkg_0.4.24.bb

OPENEULER_REPO_NAME = "yocto-embedded-tools"
OPENEULER_LOCAL_NAME = "ros-dev-tools"
OPENEULER_BRANCH = "dev_ros"
OPENEULER_GIT_URL = "https://gitee.com/openeuler"

PV = "0.6.1"

S = "${WORKDIR}/colcon-core-${PV}"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove += "${PYPI_SRC_URI} "

SRC_URI += "file://${OPENEULER_LOCAL_NAME}/ros_depends/${BPN}/colcon-core-${PV}.tar.gz "

