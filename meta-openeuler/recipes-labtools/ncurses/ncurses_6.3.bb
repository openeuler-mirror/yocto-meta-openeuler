require ncurses.inc
FILESEXTRAPATHS_append := "${THISDIR}/../../../../meta/recipes-core/ncurses/files/:"
LIC_FILES_CHKSUM="file://COPYING;md5=f852913c5d988a5f5a2f1df7ba7ee893"
SRC_URI = "file://ncurses/${BP}.tar.gz \
           file://ncurses/ncurses-config.patch \
           file://ncurses/ncurses-libs.patch \
           file://ncurses/ncurses-urxvt.patch \
           file://ncurses/ncurses-kbs.patch \
"

CFLAGS_remove_arm64eb += "-O2"
CXXFLAGS_remove_arm64eb += "-O2"
CPPFLAGS_remove_arm64eb += "-O2"
CPPFLAGS_append_arm64eb += "-Os"

EXTRA_OECONF += "--with-abi-version=5 --cache-file=${B}/config.cache"
UPSTREAM_CHECK_GITTAGREGEX = "(?P<pver>\d+(\.\d+)+(\+\d+)*)"

