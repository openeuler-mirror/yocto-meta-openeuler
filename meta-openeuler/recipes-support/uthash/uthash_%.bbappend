# mani bbfile ref: http://cgit.openembedded.org/meta-openembedded/tree/meta-oe/recipes-support/uthash?h=zeus

PV = "2.1.0"

S = "${WORKDIR}/uthash-${PV}"

# files, patches that come from openeuler
SRC_URI_remove = " \
    git://github.com/troydhanson/${BPN}.git \
"

SRC_URI_prepend = " \
        file://v${PV}.tar.gz \
"

