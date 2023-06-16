# main bb file: yocto-poky/meta/recipes-devtools/cmake/cmake_3.19.5.bb

# openEuler version
PV = "3.22.0"

SRC_URI_remove = " \
    file://0002-cmake-Prevent-the-detection-of-Qt5.patch \
"

SRC_URI += "\
    file://cmake-findruby.patch \
    file://cmake-fedora-flag_release.patch \
    file://cmake-mingw-dl.patch \
"

LIC_FILES_CHKSUM = "file://Copyright.txt;md5=31023e1d3f51ca90a58f55bcee8e2339 \
"

SRC_URI[sha256sum] = "998c7ba34778d2dfdb3df8a695469e24b11e2bfa21fbe41b361a3f45e1c9345e"
