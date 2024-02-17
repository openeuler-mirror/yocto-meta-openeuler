inherit pkgconfig

PV = "v0.370"

SRC_URI += " \
        file://v0.370.tar.gz \
"

S = "${WORKDIR}/hwdata-0.370"

do_install:append() {
    install -d ${D}${libdir}/pkgconfig/
    install -m 0644 ${S}/hwdata.pc ${D}${libdir}/pkgconfig/
}

BBCLASSEXTEND += "native"

