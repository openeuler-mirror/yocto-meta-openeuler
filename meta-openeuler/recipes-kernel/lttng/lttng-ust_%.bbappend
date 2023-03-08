# main bbfile: yocto-poky/meta/recipes-kernel/lttng/lttng-ust_2.12.1.bb

FILESEXTRAPATHS_append := "${THISDIR}/${BPN}/:"

# version in openEuler
PV = "2.13.5"

# update LICENSE checksums
LIC_FILES_CHKSUM = "file://LICENSE;md5=a46577a38ad0c36ff6ff43ccf40c480f"

# apply new poky patches
SRC_URI_append = " \
           file://0001-lttng-ust-common-link-with-liburcu-explicitly.patch \
           file://0001-Makefile.am-update-rpath-link.patch \
           "

SRC_URI[md5sum] = "9fdf788f88b3eb4fb4ced817fa0ed6c5"
SRC_URI[sha256sum] = "dfafea313b99ab94be72b23a749ce82cb3b7e60b09cf84e2370f0eebd88f4c98"
