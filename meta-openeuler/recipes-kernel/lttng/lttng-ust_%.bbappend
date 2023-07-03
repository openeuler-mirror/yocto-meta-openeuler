# main bbfile: yocto-poky/meta/recipes-kernel/lttng/lttng-ust_2.13.5.bb

# update LICENSE checksums
LIC_FILES_CHKSUM = "file://LICENSE;md5=a46577a38ad0c36ff6ff43ccf40c480f"

SRC_URI:remove = " \
    https://lttng.org/files/lttng-ust/lttng-ust-${PV}.tar.bz2 \
"

# apply new poky patches
SRC_URI:append = " \
    file://${BP}.tar.bz2 \
"

SRC_URI[md5sum] = "9fdf788f88b3eb4fb4ced817fa0ed6c5"
SRC_URI[sha256sum] = "dfafea313b99ab94be72b23a749ce82cb3b7e60b09cf84e2370f0eebd88f4c98"
