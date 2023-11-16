# main bb: meta-wayland/recipes-wlroots/wlroots/wlroots_git.bb
# from https://github.com/MarkusVolk/meta-wayland.git 

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

OPENEULER_LOCAL_NAME = "oee_archive"

PV = "0.17.0-dev"

# issue: hwdata or hwdata native not found in do_configure
# Using the host's data file as a workaround:
#    * HWdata needs to be installed on the host
SRC_URI = " \
        file://${OPENEULER_LOCAL_NAME}/${BPN}/wlroots-b560f362.tar.gz \
        file://use-hwdata-host.patch \
"

S = "${WORKDIR}/wlroots-master"

PACKAGECONFIG += " \
        ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'xwayland', '', d)} \
"
EXTRA_OEMESON += " -Dbackends=drm,libinput,x11 "

