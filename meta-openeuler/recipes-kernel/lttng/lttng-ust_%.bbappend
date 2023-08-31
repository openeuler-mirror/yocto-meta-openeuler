# main bbfile: yocto-poky/meta/recipes-kernel/lttng/lttng-ust_2.13.5.bb

# update LICENSE checksums
LIC_FILES_CHKSUM = "file://LICENSE;md5=a46577a38ad0c36ff6ff43ccf40c480f"

PV = "2.13.6"

SRC_URI:remove = " \
    https://lttng.org/files/lttng-ust/lttng-ust-${PV}.tar.bz2 \
"

# apply new poky patches
SRC_URI:append = " \
    file://${BP}.tar.bz2 \
"
