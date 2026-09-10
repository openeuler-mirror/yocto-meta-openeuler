# Upstream recipe: yocto-poky/meta/recipes-devtools/erofs-utils/erofs-utils_1.4.bb
# Source: https://atomgit.com/src-openeuler/erofs-utils (1.9.3)
PV = "1.9.3"

S = "${WORKDIR}/${BPN}-${PV}"

SRC_URI:prepend = " \
    file://${BP}.tar.gz \
"

# 1.9.3 already includes <sys/stat.h> in fsck/main.c, upstream patch is obsolete
SRC_URI:remove = " \
    file://0001-fsck-main.c-add-missing-include.patch \
"

LIC_FILES_CHKSUM = "file://COPYING;md5=63afa010baddc7d0905f9c31ac759f51"
