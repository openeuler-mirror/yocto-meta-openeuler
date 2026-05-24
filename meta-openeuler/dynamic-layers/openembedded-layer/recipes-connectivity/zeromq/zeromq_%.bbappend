# main bbfile: yocto-meta-openembedded/meta-oe/recipes-connectivity/zeromq/zeromq_4.3.4.bb

PV = "4.3.5"

SRC_URI:append = " \
        file://libzmq-${PV}.tar.gz \
"

S = "${WORKDIR}/libzmq-${PV}"
