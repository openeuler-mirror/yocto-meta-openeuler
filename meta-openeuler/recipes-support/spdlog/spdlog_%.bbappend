# main bbfile: yocto-meta-openembedded/meta-oe/recipes-support/spdlog/spdlog_1.8.2.bb

OPENEULER_REPO_NAME = "yocto-embedded-tools"
OPENEULER_LOCAL_NAME = "ros-dev-tools"
OPENEULER_BRANCH = "dev_ros"
OPENEULER_GIT_URL = "https://gitee.com/openeuler"

PV = "1.11.0"

S = "${WORKDIR}/spdlog-${PV}"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = "git://github.com/gabime/spdlog.git;protocol=https;branch=v1.x; "

SRC_URI += "file://${OPENEULER_LOCAL_NAME}/ros_depends/spdlog/v${PV}.tar.gz "

