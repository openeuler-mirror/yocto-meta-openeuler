
SUMMARY = "The x template library"
DESCRIPTION = ""
HOMEPAGE = "https://github.com/xtensor-stack/xtl"
LICENSE = "MulanPSL-2.0"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MulanPSL-2.0;md5=74b1b7a7ee537a16390ed514498bf23c"

inherit bin_package

SRC_URI:aarch64 = " \
        https://repo.oepkgs.net/openEuler/rpm/openEuler-22.03-LTS/extras/aarch64/Packages/x/xtl-0.7.4-1.aarch64.rpm;name=arm64;subdir=${BP} \
"
SRC_URI:x86-64 = " \
        https://repo.oepkgs.net/openeuler/rpm/openEuler-22.03-LTS/compatible/aur/x86_64/Packages/xtl-0.7.4-1.x86_64.rpm;name=x86;subdir=${BP} \
"

SRC_URI[arm64.md5sum] = "5fccfb9dceedbfbacd5f8b95660f414b"
SRC_URI[x86.md5sum] = "d3b2bdd6e6ae010276a9e950abb9e743"

S = "${WORKDIR}/${BP}"

FILES:${PN} = " \
    /usr/include/* \
    /usr/share/* \
"

# don't need '/etc/ima'
INSANE_SKIP:${PN} += "already-stripped installed-vs-shipped"