# bbfile yocto-meta-rockchip/recipes-kernel/rkwifibt-firmware/rkwifibt-firmware.bb

inherit oee-archive
OEE_ARCHIVE_SUB_DIR = "rkwifibt-firmware"

SRC_URI = " \
    file://rkwifibt-firmware.tar.gz \
"

S = "${WORKDIR}/rkwifibt-firmware"
