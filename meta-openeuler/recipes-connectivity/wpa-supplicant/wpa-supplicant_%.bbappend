# version in openEuler
PV = "2.12"

LIC_FILES_CHKSUM = "file://COPYING;md5=5ebcb90236d1ad640558c3d3cd3035df \
                    file://README;beginline=1;endline=56;md5=155e35cb3d6ab0d6a17524f48f4e761c \
                    file://wpa_supplicant/wpa_supplicant.c;beginline=1;endline=12;md5=f5ccd57ea91e04800edb88267bf8eae4 \
"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# apply source package in openeuler (the qt4 gui patch was replaced by
# the qt6 QRegExp fix in the src repo)
SRC_URI:prepend = " \
    file://wpa_supplicant-${PV}.tar.gz \
    file://wpa_supplicant-Revert-Mark-authorization-completed-on-driver-indica.patch \
    file://backport-CVE-2024-5290.patch \
    file://wpa_supplicant-2.12-qt6-QRegExp.patch \
"

DEPENDS += "libbsd-native"

SRC_URI[sha256sum] = "08e23937e16d0155e55cab2b51f51fbe10d80a1aa91c4e15442645059b737ef6"

S = "${WORKDIR}/wpa_supplicant-${PV}"
