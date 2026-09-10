# main bbfile: yocto-poky/meta/recipes-support/libexif/libexif_0.6.24.bb
PV = "0.6.25"

SRC_URI:prepend = " \
    file://v${PV}.tar.gz \
    file://backport-CVE-2026-32775.patch \
    file://backport-CVE-2026-40385.patch \
    file://backport-CVE-2026-40386.patch \
    "

SRC_URI[sha256sum] = "b23af41f37019b8d591d4d9b42ba52fd30709b6767341aa887f9afe400c8408a"

# the src repo tag archive misses the generated gettext files required
# by autoreconf (AM_GNU_GETTEXT); build without NLS as the mc recipe does
# for the same issue
EXTRA_OECONF += "--disable-nls"

do_configure:prepend() {
    touch ${S}/ABOUT-NLS
}

do_configure:append() {
    printf 'all:\ninstall:\nclean:\ndistdir:\n' > ${B}/po/Makefile
}