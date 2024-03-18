# main bbfile: meta-oe/recipes-support/uthash/uthash_2.3.0.bb?h=hardknott

PV = "2.3.0"

SRC_URI:prepend = " \
        file://v${PV}.tar.gz \
"

S = "${WORKDIR}/${BP}"
