# main bbfile: yocto-meta-openembedded/meta-oe/recipes-connectivity/zeromq/cppzmq_git.bb
PV = "4.9.0"
SRC_URI:prepend = " \
    file://v${PV}.tar.gz \
    "
S = "${WORKDIR}/${BP}"
