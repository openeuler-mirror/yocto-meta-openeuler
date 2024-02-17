# main bb: yocto-meta-openembedded/meta-oe/recipes-graphics/glm/glm_0.9.9.8.bb

PV = "0.9.9.8"

SRC_URI += " \
        file://glm-${PV}.tar.gz \
        file://fix-tests-big-endian-and-installation.patch \
"

S = "${WORKDIR}/glm-${PV}"
