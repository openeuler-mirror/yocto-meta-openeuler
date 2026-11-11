# main bb: yocto-meta-openembedded/meta-oe/recipes-gnome/gtk+/gtkmm3_3.24.5.bb

OPENEULER_LOCAL_NAME = "gtkmm30"

PV = "3.24.11"

SRC_URI += " \
        file://gtkmm-${PV}.tar.xz \
"

S = "${WORKDIR}/gtkmm-${PV}"

# 3.24.11 re-shipped the license texts (same LGPL-2.1 / GPL-2.0
# contents, new formatting); refresh the checksums
LIC_FILES_CHKSUM = "file://COPYING;md5=4bf661c1e3793e55c8d1051bc5e0ae21 \
                    file://COPYING.tools;md5=570a9b3749dd0463a1778803b12a6dce"
