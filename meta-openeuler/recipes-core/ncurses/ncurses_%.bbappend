PV = "6.3"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove += " \
           git://salsa.debian.org/debian/ncurses.git;protocol=https \
           file://0002-configure-reproducible.patch \
           file://0003-gen-pkgconfig.in-Do-not-include-LDFLAGS-in-generated.patch \
"

S = "${WORKDIR}/${BPN}-${PV}"
# files, patches that come from openeuler
SRC_URI += "file://ncurses/${BP}.tar.gz \
           file://ncurses/ncurses-config.patch \
           file://ncurses/ncurses-libs.patch \
           file://ncurses/ncurses-urxvt.patch \
           file://ncurses/ncurses-kbs.patch \
           file://backport-CVE-2022-29458.patch \
"

SRC_URI[md5sum] = "a2736befde5fee7d2b7eb45eb281cdbe"
