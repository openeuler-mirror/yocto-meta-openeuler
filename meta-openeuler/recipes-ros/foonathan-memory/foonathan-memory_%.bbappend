# main bbfile: yocto-meta-ros/meta-ros2/recipes-devtools/foonathan-memory/foonathan-memory_git.bb

OPENEULER_REPO_NAME = "yocto-embedded-tools"
OPENEULER_LOCAL_NAME = "ros-dev-tools"
OPENEULER_BRANCH = "dev_ros"
OPENEULER_GIT_SPACE = "openeuler"

PV = "0.6-2"

S = "${WORKDIR}/memory-${PV}"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = "git://github.com/foonathan/memory.git;branch=main;protocol=https;name=main \
    git://github.com/foonathan/compatibility.git;protocol=https;name=comp;destsuffix=git/cmake/comp;branch=master \
    git://github.com/catchorg/Catch2.git;branch=v2.x;protocol=https;name=catch;destsuffix=git/catch-upstream \
"

# from memory git, release 0.6-2 tag(we used) to 8f6a027d473f9b47965 (foonathan-memory in SRCREV_main) have 0001~0005 patches, so apply it
SRC_URI += " \
        file://${OPENEULER_LOCAL_NAME}/ros_depends/${BPN}/v${PV}.tar.gz \
        file://0001-Fix-README.patch \
        file://0002-Fix-compile-error-with-container.hpp-when-FOONATHAN_.patch \
        file://0003-Propose-to-use-the-FHS-layout-on-Windows-build.-58.patch \
        file://0004-Fix-cmake-crosscompiling-60.patch \
        file://0005-Add-funding.patch \
        file://${OPENEULER_LOCAL_NAME}/ros_depends/${BPN}/master.zip \
        file://${OPENEULER_LOCAL_NAME}/ros_depends/${BPN}/v2.12.1.tar.gz \
        "

do_unpack_append() {
    bb.build.exec_func('do_copy_source', d)
}

do_copy_source() {
    mkdir -p ${S}/cmake/comp
    mkdir -p ${S}/catch-upstream
    cp -rfp ${WORKDIR}/compatibility-master/* ${S}/cmake/comp
    cp -rfp ${WORKDIR}/Catch2-2.12.1/* ${S}/catch-upstream
}
