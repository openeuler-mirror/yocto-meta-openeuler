inherit cargo
SUMMARY = "Rust simple demo"
DESCRIPTION = "A demo using openeuler Rust toolchain"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://demo-src"
S = "${WORKDIR}/demo-src"
SRCREV = "${AUTOREV}"
