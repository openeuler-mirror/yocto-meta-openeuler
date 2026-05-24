# main bbfile: yocto-poky/meta/recipes-devtools/nasm/nasm_2.16.03.bb

PV = "2.16.01"

# upstream patches update
FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}/:"

# remove scarthgap patches that don't apply to nasm 3.01
SRC_URI:remove = "file://CVE-2022-44370.patch \
        file://0001-stdlib-Add-strlcat.patch \
        file://0002-Add-debug-prefix-map-option.patch \
"

# files, patches that come from openeuler 3.01
SRC_URI:prepend = "file://${BP}.tar.xz \
        file://enable-make-check.patch \
"
