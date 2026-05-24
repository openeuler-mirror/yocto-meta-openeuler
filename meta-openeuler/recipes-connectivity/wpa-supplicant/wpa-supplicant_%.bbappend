# version in openEuler
PV = "2.11"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# apply source package in openeuler
SRC_URI:prepend = " \
    file://wpa_supplicant-${PV}.tar.gz \
"

DEPENDS += "libbsd-native"

SRC_URI[sha256sum] = "20df7ae5154b3830355f8ab4269123a87affdea59fe74fe9292a91d0d7e17b2f"

# openEuler 2.11 source has different license headers than poky 2.10
LIC_FILES_CHKSUM = "file://COPYING;md5=5ebcb90236d1ad640558c3d3cd3035df"

S = "${WORKDIR}/wpa_supplicant-${PV}"

# poky patches that do not apply to openEuler source
SRC_URI:remove = " \
    file://0001-build-Re-enable-options-for-libwpa_client.so-and-wpa.patch \
    file://0002-Fix-removal-of-wpa_passphrase-on-make-clean.patch \
    file://0001-Install-wpa_passphrase-when-not-disabled.patch \
    file://0001-PEAP-client-Update-Phase-2-authentication-requiremen.patch \
    file://CVE-2024-3596_00.patch \
    file://CVE-2024-3596_01.patch \
    file://CVE-2024-3596_02.patch \
    file://CVE-2024-3596_03.patch \
    file://CVE-2024-3596_04.patch \
    file://CVE-2024-3596_05.patch \
    file://CVE-2024-3596_06.patch \
    file://CVE-2024-3596_07.patch \
    file://CVE-2024-3596_08.patch \
    file://0001-SAE-Check-for-invalid-Rejected-Groups-element-length.patch \
    file://0002-SAE-Check-for-invalid-Rejected-Groups-element-length.patch \
    file://0003-SAE-Reject-invalid-Rejected-Groups-element-in-the-pa.patch \
    file://CVE-2022-37660-0001.patch \
    file://CVE-2022-37660-0002.patch \
    file://CVE-2022-37660-0003.patch \
    file://CVE-2022-37660-0004.patch \
    file://CVE-2022-37660-0005.patch \
    file://CVE-2025-24912-01.patch \
    file://CVE-2025-24912-02.patch \
"
