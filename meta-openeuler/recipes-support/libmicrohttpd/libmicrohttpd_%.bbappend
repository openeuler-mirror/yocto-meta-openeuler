# main bb file: yocto-poky/meta/recipes-support/libmicrohttpd/libmicrohttpd_0.9.76.bb

PV = "1.0.1"

SRC_URI:append = " \
    file://${BP}.tar.gz \
    file://fixed-missing-websocket.inc-in-dist-files.patch \
"

SRC_URI[sha256sum] = "a89e09fc9b4de34dde19f4fcb4faaa1ce10299b9908db1132bbfa1de47882b94"
