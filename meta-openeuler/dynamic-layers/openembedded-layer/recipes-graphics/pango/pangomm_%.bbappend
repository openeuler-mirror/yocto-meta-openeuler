# main bb: yocto-meta-openembedded/meta-oe/recipes-graphics/pango/pangomm_2.46.2.bb

PV = "2.46.5"

# 2.46.5 re-shipped the license texts (same LGPL-2.1 / GPL-2.0
# contents, new formatting); refresh the checksums
LIC_FILES_CHKSUM = "file://COPYING;md5=4bf661c1e3793e55c8d1051bc5e0ae21 \
                    file://COPYING.tools;md5=570a9b3749dd0463a1778803b12a6dce"

SRC_URI += " \
        file://${BP}.tar.xz \
"

S = "${WORKDIR}/${BP}"
