# main bb file: yocto-poky/meta/recipes-devtools/mtd/mtd-utils_git.bb

PV = "2.2.0"

SRC_URI:prepend = " \
    file://${BP}.tar.bz2 \
"

SRC_URI[sha256sum] = "daff77125e63ada25d84634bae8c29665029977afc0cc490c714dff6a37a8385"

S = "${WORKDIR}/${BP}"

EXTRA_OECONF:remove = "--enable-install-tests"
