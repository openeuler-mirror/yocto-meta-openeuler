# main bb: yocto-poky/meta/recipes-core/seatd/seatd_0.6.4.bb

inherit oee-archive

PV = "0.6.4"

SRC_URI += "file://${BP}.tar.gz \
"

S = "${WORKDIR}/${BP}"
