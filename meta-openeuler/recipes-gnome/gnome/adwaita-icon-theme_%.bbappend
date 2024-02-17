PV = "44.0"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

SRC_URI:remove = " \
    file://0001-Run-installation-commands-as-shell-jobs.patch \
"

# add default repo
SRC_URI:prepend = " \
    file://${BP}.tar.xz \
"

S = "${WORKDIR}/${BP}"

DEPENDS += " librsvg "
DEPENDS:remove = "librsvg-native"
