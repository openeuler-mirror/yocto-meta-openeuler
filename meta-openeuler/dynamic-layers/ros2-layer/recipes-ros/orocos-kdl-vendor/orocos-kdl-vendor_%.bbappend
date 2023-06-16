PV = "0.2.5"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

SRC_URI:prepend = " \
        file://find-orocos.patch \
        "
