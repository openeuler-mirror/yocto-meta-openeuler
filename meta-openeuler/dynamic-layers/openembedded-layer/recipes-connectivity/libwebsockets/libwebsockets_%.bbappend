# source bb: meta-oe/recipes-connectivity/libwebsockets/libwebsockets_4.1.6.bb;branch=hardknott

PV = "4.3.0"

LIC_FILES_CHKSUM = "file://LICENSE;md5=382bfdf329e774859fd401eaf850d29b"

OPENEULER_SRC_URI_REMOVE = "git"

# apply openeuler source and patch
SRC_URI:prepend = "file://${BP}.tar.gz \
           file://0001-add-secure-compile-option-in-Makefile.patch \
           file://0002-solve-the-BEP-problem.patch \
           file://0003-route-extend-lws_route_uidx_t-from-1-byte-to-2-bytes.patch \
"

S = "${WORKDIR}/${BP}"

SRC_URI[md5sum] = "0f82cf061d50d4a2492c32aa149cd930"
SRC_URI[sha256sum] = "e6693ab5aa925930b2c6471129b42a79b8f3cbbc493e5f8b89311cecc0c99bc0"

# no libwebsockets-test-server
EXTRA_OECMAKE:append = " \
        -DLWS_WITHOUT_TEST_SERVER=ON"
