PV = "3.31.12"

# apply openeuler source package and patches
SRC_URI:prepend = " \
           file://cmake-${PV}.tar.gz \
           file://cmake-findruby.patch \
           file://cmake-3.31.11-sw.patch \
           file://backport-CVE-2025-9301.patch \
           file://backport-archive-path-traversal.patch \
           file://backport-restore-archive-extraction-symlinks.patch \
"

LIC_FILES_CHKSUM:remove = "file://Copyright.txt;md5=31023e1d3f51ca90a58f55bcee8e2339"
LIC_FILES_CHKSUM:prepend = "file://Copyright.txt;md5=718f05155941b33862726348d3cd46ce "


SRC_URI:remove = "https://cmake.org/files/v${CMAKE_MAJOR_VERSION}/cmake-${PV}.tar.gz"

SRC_URI[sha256sum] = "5f3fd5a54dfa65602bdbed64f981a72673cc19f2d304cc2955cf0dfa0cfd8272"
