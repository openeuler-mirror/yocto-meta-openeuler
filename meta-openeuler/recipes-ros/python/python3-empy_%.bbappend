# main bbfile: yocto-meta-ros/meta-ros-common/recipes-devtools/python/python3-empy_3.3.2.bb

OPENEULER_REPO_NAME = "yocto-embedded-tools"
OPENEULER_LOCAL_NAME = "ros-dev-tools"
OPENEULER_BRANCH = "dev_ros"
OPENEULER_GIT_URL = "https://gitee.com/openeuler"

PV = "3.3.4"

LIC_FILES_CHKSUM = "file://README;md5=10d1c4f6d15ab0aa52e80cc7d6ca0959"

SRC_URI[md5sum] = "6d73ddc0e9dc76cd607217f14d742679"
SRC_URI[sha256sum] = "73ac49785b601479df4ea18a7c79bc1304a8a7c34c02b9472cf1206ae88f01b3"

S = "${WORKDIR}/empy-${PV}"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = "http://www.alcyone.com/software/empy/empy-${PV}.tar.gz "

SRC_URI += "file://${OPENEULER_LOCAL_NAME}/ros_depends/${BPN}/empy-${PV}.tar.gz "

