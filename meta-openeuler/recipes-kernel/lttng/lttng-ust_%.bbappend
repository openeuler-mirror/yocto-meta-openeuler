# main bbfile: yocto-poky/meta/recipes-kernel/lttng/lttng-ust_2.13.5.bb

# update LICENSE checksums
LIC_FILES_CHKSUM = "file://LICENSE;md5=a46577a38ad0c36ff6ff43ccf40c480f"

PV = "2.13.7"

# update patch in oe-core
FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

# apply new poky patches
SRC_URI:append = " \
    file://${BP}.tar.bz2 \
"
