inherit pkgconfig

PV = "v0.372"

SRC_URI += " \
        file://${PV}.tar.gz \
"

S = "${WORKDIR}/hwdata-0.372"

do_install:append() {
    install -d ${D}${libdir}/pkgconfig/
    install -m 0644 ${S}/hwdata.pc ${D}${libdir}/pkgconfig/
}

BBCLASSEXTEND += "native"

