# version in openEuler
PV = "2.10"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# apply source package in openeuler
SRC_URI:prepend = " \
    file://wpa_supplicant-${PV}.tar.gz \
	file://wpa_supplicant-gui-qt4.patch \
"

DEPENDS += "libbsd-native"

SRC_URI[sha256sum] = "20df7ae5154b3830355f8ab4269123a87affdea59fe74fe9292a91d0d7e17b2f"

S = "${WORKDIR}/wpa_supplicant-${PV}"

