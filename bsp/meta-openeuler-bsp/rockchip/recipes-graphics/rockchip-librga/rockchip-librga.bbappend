# bbfile yocto-meta-rockchip/recipes-graphics/rockchip-librga/rockchip-librga.bb

inherit oee-archive
OEE_ARCHIVE_SUB_DIR = "rockchip-librga"

SRC_URI = " \
    file://rockchip-rga-multi.tar.gz \
"

S = "${WORKDIR}/rockchip-rga-multi"
