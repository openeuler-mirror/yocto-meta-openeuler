# main bb file: yocto-poky/meta/recipes-graphics/wayland/weston_10.0.2.bb

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

# openeuler customization
SRC_URI:append = " \
    file://openeuler.png \
"

do_install:append() {
    install -m 644 ${WORKDIR}/openeuler.png ${D}${datadir}/weston/
}
