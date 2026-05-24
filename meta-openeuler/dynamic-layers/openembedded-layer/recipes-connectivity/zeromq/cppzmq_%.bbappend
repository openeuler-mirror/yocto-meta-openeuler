# main bbfile: yocto-meta-openembedded/meta-oe/recipes-connectivity/zeromq/cppzmq_git.bb
PV = "4.10.0"
SRC_URI:prepend = " \
    file://v${PV}.tar.gz \
    file://0-compile-with-catch2-3.patch \
    file://cppzmq-install-pkgconfig-into-datadir.patch \
    "
S = "${WORKDIR}/${BP}"
