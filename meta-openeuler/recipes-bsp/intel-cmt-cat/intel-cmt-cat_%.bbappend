# main bb: meta-intel/recipes-bsp/intel-cmt-cat/intel-cmt-cat_4.6.0.bb
# ref: git://git.yoctoproject.org/meta-intel


FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

PV = "4.6.0"

SRC_URI += " \
        file://v${PV}.tar.gz \
"

S = "${WORKDIR}/${BP}"
