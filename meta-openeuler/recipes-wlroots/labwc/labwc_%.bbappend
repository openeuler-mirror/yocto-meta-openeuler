# main bb: meta-wayland/recipes-wlroots/labwc/labwc_git.bb
# from https://github.com/MarkusVolk/meta-wayland.git

OPENEULER_LOCAL_NAME = "oee_archive"

PV = "0.7.2"

DEPENDS:remove = " wlroots-0.16 "
DEPENDS:append = " wlroots "

SRC_URI += " \
    file://${OPENEULER_LOCAL_NAME}/${BPN}/${PV}.tar.gz \
    file://autostart \
"

S = "${WORKDIR}/${BP}"

# make a lite version
RRECOMMENDS:${PN} = " labwc-tweaks-gtk sfwbar swaybg kanshi wlr-randr "

# we force to use xwayland
PACKAGECONFIG:append = " xwayland "

do_install:append() {
    install -d ${D}/etc/xdg/labwc
    install -m 755 -D ${WORKDIR}/autostart ${D}/etc/xdg/labwc/autostart
}
