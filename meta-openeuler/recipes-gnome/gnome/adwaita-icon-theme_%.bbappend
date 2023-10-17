PV = "44.0"

OPENEULER_SRC_URI_REMOVE = "https http git"

# find patches under openeuler at firse
FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

SRC_URI:remove = " \
    file://0001-Run-installation-commands-as-shell-jobs.patch \
"

# add default repo
SRC_URI:prepend = " \
    file://adwaita-icon-theme-${PV}.tar.xz \
"

S = "${WORKDIR}/${BP}"

DEPENDS += " librsvg "
DEPENDS:remove = "librsvg-native"

