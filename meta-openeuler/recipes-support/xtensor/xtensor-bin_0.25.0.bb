
SUMMARY = "C++ tensors with broadcasting and lazy computing"
DESCRIPTION = ""
HOMEPAGE = "https://github.com/xtensor-stack/xtensor"
LICENSE = "MulanPSL-2.0"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MulanPSL-2.0;md5=74b1b7a7ee537a16390ed514498bf23c"

inherit bin_package

SRC_URI:aarch64 = " \
        https://mirrors.aliyun.com/fedora/releases/42/Everything/aarch64/os/Packages/x/xtensor-devel-0.25.0-2.fc41.aarch64.rpm;name=arm64;subdir=${BP} \
"
SRC_URI:x86-64 = " \
        https://mirrors.aliyun.com/fedora/releases/42/Everything/x86_64/os/Packages/x/xtensor-devel-0.25.0-2.fc41.x86_64.rpm;name=x86;subdir=${BP} \
"

SRC_URI[arm64.md5sum] = "00f225af4fb83d1967115a2e920cb939"
SRC_URI[x86.md5sum] = "5994264ff52e0a313f353a83213f9448"

S = "${WORKDIR}/${BP}"

FILES:${PN}-dev = " \
    /usr/include/* \
    /usr/share/* \
"

DEPENDS = "xtl-bin"

# don't need '/etc/ima'
INSANE_SKIP:${PN} += "already-stripped installed-vs-shipped"

RDEPENDS:${PN}-dev = ""
ALLOW_EMPTY:${PN} = "1"
