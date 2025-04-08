# bbfile yocto-meta-rockchip/recipes-graphics/drm-cursor/drm-cursor.bb

inherit oee-archive
OEE_ARCHIVE_SUB_DIR = "drm-cursor"

SRC_URI = " \
    file://drm-cursor.tar.gz;subdir=drm-cursor \
"

S = "${WORKDIR}/drm-cursor"
