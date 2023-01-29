# main bbfile: yocto-meta-openembedded/meta-oe/recipes-test/googletest/googletest_git.bb

OPENEULER_REPO_NAME = "yocto-embedded-tools"
OPENEULER_LOCAL_NAME = "ros-dev-tools"
OPENEULER_BRANCH = "dev_ros"
OPENEULER_GIT_URL = "https://gitee.com/openeuler"

# version in openEuler
PV = "1.10.0"

S = "${WORKDIR}/googletest-release-${PV}"
SRC_URI_remove = " \
            git://github.com/google/googletest.git;branch=main;protocol=https \
            "

SRC_URI += "file://${OPENEULER_LOCAL_NAME}/ros_depends/googletest/release-${PV}.tar.gz "

