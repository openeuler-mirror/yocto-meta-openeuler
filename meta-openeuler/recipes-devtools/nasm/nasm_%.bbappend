# main bbfile: yocto-poky/meta/recipes-devtools/nasm/nasm_2.15.05.bb

OPENEULER_SRC_URI_REMOVE = "http git"

PV = "2.16.01"

# upstream patches update
FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}/:"

SRC_URI:remove = "file://CVE-2022-44370.patch"

# files, patches that come from openeuler
SRC_URI:prepend = "file://${BP}.tar.xz \
        file://enable-make-check.patch \
        file://fix-help-info-error.patch \
"
