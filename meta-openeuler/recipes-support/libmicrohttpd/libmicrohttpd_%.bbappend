# main bb file: yocto-poky/meta/recipes-support/libmicrohttpd/libmicrohttpd_0.9.76.bb

PV = "0.9.77"

SRC_URI:append = " \
    file://${BP}.tar.gz \
    file://0001-gnutls-utilize-system-crypto-policy.patch \
    file://fix-libmicrohttpd-tutorial-info.patch \
    file://fixed-missing-websocket.inc-in-dist-files.patch \
"

SRC_URI[sha256sum] = "9278907a6f571b391aab9644fd646a5108ed97311ec66f6359cebbedb0a4e3bb"
