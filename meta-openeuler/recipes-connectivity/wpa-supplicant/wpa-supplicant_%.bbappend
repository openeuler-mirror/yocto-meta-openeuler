# version in openEuler
PV = "2.10"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# apply source package in openeuler
SRC_URI:prepend = " \
    file://wpa_supplicant-${PV}.tar.gz \
	file://wpa_supplicant-gui-qt4.patch \
"

S = "${WORKDIR}/wpa_supplicant-${PV}"

