# source bb: meta-oe/recipes-connectivity/libwebsockets/libwebsockets_4.1.6.bb;branch=hardknott

PV = "4.3.2"

LIC_FILES_CHKSUM = "file://LICENSE;md5=382bfdf329e774859fd401eaf850d29b"

OPENEULER_SRC_URI_REMOVE = "git"

# apply openeuler source and patch
SRC_URI:prepend = "file://${BP}.tar.gz \
           file://0001-add-secure-compile-option-in-Makefile.patch \
           file://0002-solve-the-BEP-problem.patch \
"

S = "${WORKDIR}/${BP}"

# no libwebsockets-test-server
EXTRA_OECMAKE:append = " \
        -DLWS_WITHOUT_TEST_SERVER=ON"
