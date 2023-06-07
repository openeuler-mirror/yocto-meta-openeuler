OPENEULER_SRC_URI_REMOVE = "https git http"

PV = "6.3"

# files, patches can't be applied in openeuler or conflict with openeuler
# CVE-2021-39537.patch from poky is for 6.2 and no need for openeuler 6.3 version
SRC_URI_remove += " \
            file://0002-configure-reproducible.patch \
            file://0003-gen-pkgconfig.in-Do-not-include-LDFLAGS-in-generated.patch \
            file://CVE-2021-39537.patch \
"

S = "${WORKDIR}/${BPN}-${PV}"
# files, patches that come from openeuler
SRC_URI += "file://ncurses/${BP}.tar.gz \
           file://ncurses/ncurses-config.patch \
           file://ncurses/ncurses-libs.patch \
           file://ncurses/ncurses-urxvt.patch \
           file://ncurses/ncurses-kbs.patch \
           file://ncurses/backport-CVE-2022-29458.patch \
"

SRC_URI[md5sum] = "a2736befde5fee7d2b7eb45eb281cdbe"
