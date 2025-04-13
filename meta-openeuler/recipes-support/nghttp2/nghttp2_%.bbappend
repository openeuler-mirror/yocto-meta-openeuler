#bbfile: yocto-poky/meta/recipes-support/nghttp2/nghttp2_1.47.0.bb

PV = "1.58.0"

SRC_URI += " \
        file://${BP}.tar.xz \
        file://backport-CVE-2024-28182-1.patch \
        file://backport-CVE-2024-28182-2.patch \
"

# accroding to nghttp2-1.57.0.bb, no nghttp2-client and nghttp2-server
RDEPENDS:${PN} = "${PN}-proxy (>= ${PV}) "
