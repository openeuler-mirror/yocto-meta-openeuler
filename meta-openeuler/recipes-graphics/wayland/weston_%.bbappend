# main bb file: yocto-poky/meta/recipes-graphics/wayland/weston_10.0.2.bb

OPENEULER_BRANCH = "master"

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

PV = "8.0.0"

# License on 8.0.0
LIC_FILES_CHKSUM = "file://COPYING;md5=d79ee9e66bb0f95d3386a7acae780b70 \
                    file://libweston/compositor.c;endline=27;md5=6c53bbbd99273f4f7c4affa855c33c0a"


SRC_URI[sha256sum] = "7518b49b2eaa1c3091f24671bdcc124fd49fc8f1af51161927afa4329c027848"

# keep as 8.0.0
EXTRA_OEMESON += "-Dbackend-default=auto"

PACKAGECONFIG[fbdev] = "-Dbackend-fbdev=true,-Dbackend-fbdev=false,udev mtdev"

PACKAGECONFIG[launch] = "-Dweston-launch=true,-Dweston-launch=false,drm"

PACKAGECONFIG[launcher-libseat] = ""


# openeuler customization
DEPENDS:remove = "gdk-pixbuf"

SRC_URI:append = "file://openeuler.png \
"

do_install:append() {
    install -m 644 ${WORKDIR}/openeuler.png ${D}${datadir}/weston/
}
