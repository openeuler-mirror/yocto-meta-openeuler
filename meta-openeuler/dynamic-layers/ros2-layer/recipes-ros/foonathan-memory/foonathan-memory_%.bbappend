# main bbfile: yocto-meta-ros/meta-ros2/recipes-devtools/foonathan-memory/foonathan-memory_git.bb
inherit openeuler_ros_source

PV = "0.6-2"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

# from memory git, release 0.6-2 tag(we used) to 8f6a027d473f9b47965 (foonathan-memory in SRCREV_main) have 0001~0005 patches, so apply it
SRC_URI += " \
        file://0001-Fix-README.patch \
        file://0002-Fix-compile-error-with-container.hpp-when-FOONATHAN_.patch \
        file://0003-Propose-to-use-the-FHS-layout-on-Windows-build.-58.patch \
        file://0004-Fix-cmake-crosscompiling-60.patch \
        file://0005-Add-funding.patch \
        "

