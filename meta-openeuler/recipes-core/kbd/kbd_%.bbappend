# main bb file: yocto-poky/meta/recipes-core/kbd/kbd_2.4.0.bb

PV = "2.6.1"

# license update
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

# use patches from src-openEuler
SRC_URI:prepend = "file://kbd-${PV}.tar.xz \
           file://kbd-1.15-keycodes-man.patch \
           file://kbd-1.15-sparc.patch \
           file://kbd-1.15-unicode_start.patch \
           file://kbd-1.15.5-sg-decimal-separator.patch \
           file://kbd-1.15.5-loadkeys-search-path.patch \
           file://kbd-2.0.2-unicode-start-font.patch \
           file://kbd-2.4.0-covscan-fixes.patch \
           "

SRC_URI[sha256sum] = "ccdf452387a6380973d2927363e9cbb939fa2068915a6f937ff9d24522024683"

EXTRA_OECONF = "--disable-tests"
