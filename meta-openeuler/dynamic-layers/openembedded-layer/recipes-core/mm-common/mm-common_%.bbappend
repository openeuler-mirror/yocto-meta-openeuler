# main bb: yocto-meta-openembedded/meta-oe/recipes-core/mm-common/mm-common_1.0.4.bb

PV = "1.0.5"

# this patch just for 1.0.4
SRC_URI:remove = " \
        file://0001-meson.build-do-not-ask-for-python-installation-versi.patch \
"

SRC_URI += " \
        file://${BP}.tar.xz \
"

S = "${WORKDIR}/${BP}"
