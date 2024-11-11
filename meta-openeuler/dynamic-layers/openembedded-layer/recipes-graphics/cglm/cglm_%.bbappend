# main bb: meta-openembedded/tree/meta-oe/recipes-graphics/cglm/cglm_0.9.1.bb
# from https://git.openembedded.org/

inherit oee-archive

PV = "0.9.1"

SRC_URI += "file://${BP}.tar.gz \
"

S = "${WORKDIR}/${BP}"
