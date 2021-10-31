require ncurses.inc
FILESEXTRAPATHS_append := "${THISDIR}/../../../../meta/recipes-core/ncurses/files/:"
LIC_FILES_CHKSUM="file://COPYING;md5=910e05334f7e0b7631da6b4ebb1e1aab"
SRC_URI = "file://ncurses/ncurses-6.2.tar.gz"

CFLAGS_remove_arm64eb += "-O2"
CXXFLAGS_remove_arm64eb += "-O2"
CPPFLAGS_remove_arm64eb += "-O2"
CPPFLAGS_append_arm64eb += "-Os"

EXTRA_OECONF += "--with-abi-version=5 --cache-file=${B}/config.cache"
UPSTREAM_CHECK_GITTAGREGEX = "(?P<pver>\d+(\.\d+)+(\+\d+)*)"

