SUMMARY = "An SVG library based on cairo"
DESCRIPTION = "a version use binary from openeuler"
HOMEPAGE = "https://wiki.gnome.org/Projects/LibRsvg"
LICENSE = "LGPLv2+"

LIC_FILES_CHKSUM = "file://usr/share/licenses/librsvg2/COPYING.LIB;md5=4fbd65380cdd255951079008b364516c"

REMOTE_RPM_NAME:aarch64 = "librsvg2-2.50.5-3.oe2203sp2.aarch64.rpm"
REMOTE_DEV_RPM_NAME:aarch64 ="librsvg2-devel-2.50.5-3.oe2203sp2.aarch64.rpm"

REMOTE_RPM_NAME:x86-64 = "librsvg2-2.50.5-3.oe2203sp2.x86_64.rpm"
REMOTE_DEV_RPM_NAME:x86-64 = "librsvg2-devel-2.50.5-3.oe2203sp2.x86_64.rpm"

SRC_URI[arm64.md5sum] = "cda67a29cf7e551603de840e4605dc55"
SRC_URI[arm64dev.md5sum] = "08d7e9181a0d247077fff5c9bf0dd8de"
SRC_URI[x86.md5sum] = "dd564a81f8796c70212c1c8752485a7b"
SRC_URI[x86dev.md5sum] = "7799c9766b4ea5892ebbbe2e32339a6b"

INHIBIT_DEFAULT_DEPS = "1"

inherit pkgconfig

DEPENDS = "cairo gdk-pixbuf glib-2.0 libcroco libxml2 pango"

SRC_URI = " \
        file://librsvg.pc.in \
"

SRC_URI:append:aarch64 = " \
        https://repo.openeuler.org/openEuler-22.03-LTS-SP2/everything/aarch64/Packages/librsvg2-2.50.5-3.oe2203sp2.aarch64.rpm;name=arm64 \
        https://repo.openeuler.org/openEuler-22.03-LTS-SP2/everything/aarch64/Packages/librsvg2-devel-2.50.5-3.oe2203sp2.aarch64.rpm;name=arm64dev \
"

SRC_URI:append:x86-64 = " \
        https://repo.openeuler.org/openEuler-22.03-LTS-SP2/everything/x86_64/Packages/librsvg2-2.50.5-3.oe2203sp2.x86_64.rpm;name=x86 \
        https://repo.openeuler.org/openEuler-22.03-LTS-SP2/everything/x86_64/Packages/librsvg2-devel-2.50.5-3.oe2203sp2.x86_64.rpm;name=x86dev \
"

S = "${WORKDIR}"

do_install:append() {
    install -d ${D}${includedir}
    cp -rf -P ${S}/${includedir}/* ${D}${includedir}

    install -d ${D}${libdir}
    cp -rf -P ${S}/${libdir}/* ${D}${libdir}

    install -d ${D}${datadir}
    cp -rf -P ${S}/${datadir}/* ${D}${datadir}

    sed \
    -e s#@VERSION@#${PV}# \
    -e s#@RSVG_API_MAJOR_VERSION@#2# \
    -e s#@RSVG_API_VERSION@#2.0# \
    -e s#@prefix@#${prefix}# \
    -e s#@exec_prefix@#${exec_prefix}# \
    -e s#@libdir@#${libdir}# \
    -e s#@includedir@#${includedir}# \
    ${WORKDIR}/librsvg.pc.in > ${WORKDIR}/librsvg-2.0.pc

    install -d ${D}${libdir}/pkgconfig
    install -m 0644 ${WORKDIR}/librsvg-2.0.pc ${D}${libdir}/pkgconfig/
}

FILES:${PN} = " \
    ${datadir} \
    ${libdir} \
"
 
FILES:${PN}-dev = " \
    ${libdir}/librsvg-2.so \
    ${includedir} \
"

INSANE_SKIP:${PN} += "already-stripped dev-deps"

