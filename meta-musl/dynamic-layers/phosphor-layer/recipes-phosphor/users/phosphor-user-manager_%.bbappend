FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI:append = " \
        file://phosphor-user-manager-musl.patch \
"
