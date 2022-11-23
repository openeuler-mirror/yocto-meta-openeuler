PV = "6.3"

# files, patches can't be applied in openeuler or conflict with openeuler
# CVE-2021-39537.patch from poky is for 6.2 and no need for openeuler 6.3 version
SRC_URI_remove += " \
            git://salsa.debian.org/debian/ncurses.git;protocol=https \
            git://salsa.debian.org/debian/ncurses.git;protocol=https;branch=master \
            file://0002-configure-reproducible.patch \
            file://0003-gen-pkgconfig.in-Do-not-include-LDFLAGS-in-generated.patch \
            file://CVE-2021-39537.patch \
"

# files, patches that come from openeuler
SRC_URI_prepend += "file://${BP}.tar.gz \
           file://ncurses-config.patch \
           file://ncurses-libs.patch \
           file://ncurses-urxvt.patch \
           file://ncurses-kbs.patch \
           file://backport-CVE-2022-29458.patch \
"

SRC_URI[sha256sum] = "97fc51ac2b085d4cde31ef4d2c3122c21abc217e9090a43a30fc5ec21684e059"

S = "${WORKDIR}/${BP}"
