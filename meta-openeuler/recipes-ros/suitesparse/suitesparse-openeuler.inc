#reference: yocto-meta-ros/meta-ros-common/recipes-extended/suitesparse/suitesparse-5.4.0.inc
inherit ros_distro_foxy

# current version in openeuler is too old to compile suitesparse-cholmod
# we use the one version sync with meta-ros, which is in in yocto-embedded-tools/dev_ros
OPENEULER_REPO_NAME = "yocto-embedded-tools"
OPENEULER_LOCAL_NAME = "ros-dev-tools"
OPENEULER_BRANCH = "dev_ros"
OPENEULER_GIT_SPACE = "openeuler"
OPENEULER_SRC_URI_REMOVE = "git https http"

# files, patches that come from openeuler
SRC_URI_prepend = " \
    file://ros-dev-tools/ros_depends/suitesparse/SuiteSparse-5.4.0.tar.gz \
"

