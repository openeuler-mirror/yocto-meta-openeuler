# main bbfile: yocto-poky/meta/recipes-devtools/nasm/nasm_2.15.05.bb

PV = "2.16.03"

# upstream patches update
FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}/:"

# files, patches that come from openeuler
SRC_URI = "file://${BP}.tar.xz \
        file://enable-make-check.patch \
        file://fix-help-info-error.patch \
"
SRC_URI[sha256sum] = "bef3de159bcd61adf98bb7cc87ee9046e944644ad76b7633f18ab063edb29e57"
