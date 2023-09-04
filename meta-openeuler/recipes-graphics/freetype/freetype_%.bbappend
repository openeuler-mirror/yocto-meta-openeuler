# the main bb file: yocto-poky/meta/recipes-graphics/freetype/freetype_2.11.1.bb
# version in src-openEuler

PV = "2.13.1"

LICENSE = "(FTL | GPL-2.0-or-later) & MIT"

SRC_URI:remove = " \
    ${SAVANNAH_GNU_MIRROR}/${BPN}/${BP}.tar.xz \
    file://CVE-2022-27404.patch \
    file://CVE-2022-27405.patch \
    file://CVE-2022-27406.patch \
    file://CVE-2023-2004.patch \
"
# apply src-openEuler patches
# backport-freetype-2.5.2-more-demos.patch for ft2demos
SRC_URI:prepend = " \
    file://freetype-${PV}.tar.xz \
    file://backport-freetype-2.3.0-enable-spr.patch \
    file://backport-freetype-2.2.1-enable-valid.patch \
    file://backport-freetype-2.6.5-libtool.patch \
    file://backport-freetype-2.8-multilib.patch \
    file://backport-freetype-2.10.0-internal-outline.patch \
    file://backport-freetype-2.10.1-debughook.patch \
"

LIC_FILES_CHKSUM = "file://LICENSE.TXT;md5=843b6efc16f6b1652ec97f89d5a516c0 \
"

# new checksum
SRC_URI[sha256sum] = "ea67e3b019b1104d1667aa274f5dc307d8cbd606b399bc32df308a77f1a564bf"

# when running compile task, it will put libtool can not be find, but we can find libtool with arch
# so make a software link from arch libtool to libtool
do_configure:append() {
    if [ ! -f "libtool" ];then
        ln -s $(ls | grep *libtool) libtool
    fi
}
