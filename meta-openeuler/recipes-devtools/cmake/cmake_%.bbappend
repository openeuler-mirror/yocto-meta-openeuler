# main bb file: yocto-poky/meta/recipes-devtools/cmake/cmake_3.19.5.bb

OPENEULER_SRC_URI_REMOVE = "https git http"

# openEuler version
PV = "3.22.0"

SRC_URI_remove = " \
    file://0002-cmake-Prevent-the-detection-of-Qt5.patch \
"

SRC_URI += "\
    file://cmake-${PV}.tar.gz \
    file://cmake-findruby.patch \
    file://cmake-fedora-flag_release.patch \
    file://cmake-mingw-dl.patch \
    file://cmake-3.22.0-sw.patch \
"

LIC_FILES_CHKSUM = "file://Copyright.txt;md5=31023e1d3f51ca90a58f55bcee8e2339 \
"
