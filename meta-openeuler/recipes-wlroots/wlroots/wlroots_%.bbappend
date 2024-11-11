# main bb: meta-wayland/recipes-wlroots/wlroots/wlroots_git.bb
# from https://github.com/MarkusVolk/meta-wayland.git 
FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

inherit oee-archive

PV = "0.17.2"

# issue: hwdata or hwdata native not found in do_configure
# Using the host's data file as a workaround:
#    * HWdata needs to be installed on the host
SRC_URI += " \
        file://wlroots-${PV}.tar.gz \
        file://use-hwdata-host.patch \
"

S = "${WORKDIR}/wlroots-${PV}"

PACKAGECONFIG += " \
        ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xwayland', '', d)} \
"
EXTRA_OEMESON += " -Dbackends=drm,libinput,x11 "
