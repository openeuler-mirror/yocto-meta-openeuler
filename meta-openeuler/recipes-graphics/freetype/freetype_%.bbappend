# the main bb file: yocto-poky/meta/recipes-graphics/freetype/freetype_2.11.1.bb
# version in src-openEuler

PV = "2.12.1"

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

LIC_FILES_CHKSUM = "file://LICENSE.TXT;md5=a5927784d823d443c6cae55701d01553 \
"

# new checksum
SRC_URI[sha256sum] = "ce729d97f166a919a6a3037c949af01d5d6e1783614024d72683153f0bc5ef05"

# when running compile task, it will put libtool can not be find, but we can find libtool with arch
# so make a software link from arch libtool to libtool
do_configure:append() {
    if [ ! -f "libtool" ];then
        ln -s $(ls | grep *libtool) libtool
    fi
}
