PV = "3.27.9"

# apply openeuler source package and patches
SRC_URI:prepend = " \
           file://cmake-${PV}.tar.gz \
           file://cmake-findruby.patch \
"

LIC_FILES_CHKSUM:remove = "file://Copyright.txt;md5=31023e1d3f51ca90a58f55bcee8e2339"
LIC_FILES_CHKSUM:prepend = "file://Copyright.txt;md5=9d3d12c5f3b4c1f83650adcc65b59c06 "


SRC_URI:remove = "https://cmake.org/files/v${CMAKE_MAJOR_VERSION}/cmake-${PV}.tar.gz"

SRC_URI[sha256sum] = "609a9b98572a6a5ea477f912cffb973109ed4d0a6a6b3f9e2353d2cdc048708e"
