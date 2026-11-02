# main bb: yocto-meta-openembedded/meta-oe/recipes-core/glib-2.0/glibmm_2.66.2.bb

OPENEULER_LOCAL_NAME = "glibmm24"

PV = "2.66.10"

SRC_URI += " \
        file://${BP}.tar.xz \
        file://glibmm24-gcc11.patch \
"

S = "${WORKDIR}/${BP}"

# LIC files changed in 2.66.10
LIC_FILES_CHKSUM = "file://COPYING;md5=4bf661c1e3793e55c8d1051bc5e0ae21 \
                    file://COPYING.tools;md5=570a9b3749dd0463a1778803b12a6dce"
