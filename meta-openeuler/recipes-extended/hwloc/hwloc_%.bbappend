# bb file: ./yocto-meta-openembedded/meta-oe/recipes-extended/hwloc/hwloc_1.11.13.bb

LIC_FILES_CHKSUM = "file://COPYING;md5=79179bb373cd55cbd834463a514fb714"

PV = "2.11.2"

SRC_URI = "\
        file://hwloc-${PV}.tar.bz2 \
"

SRC_URI[md5sum] = "4bb1d9bdf550a95fea4f588d8911b8e2"
SRC_URI[sha256sum] = "f7f88fecae067100f1a1a915b658add0f4f71561259482910a69baea22fe8409"

PACKAGECONFIG[numactl] = "--enable-libnuma,numactl,numactl"

FILES:${PN} += "/usr/share/bash-completion/completions/hwloc"
