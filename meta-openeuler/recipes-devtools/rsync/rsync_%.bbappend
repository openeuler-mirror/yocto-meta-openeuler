PV = "3.5.1"

# patch files and rsyncd.conf overlaid from the OE-Core master rsync_3.5.1
# recipe (the src repo tarball is byte-identical to the upstream release)
FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

SRC_URI:prepend = " \
        file://${BP}.tar.gz \
        "

SRC_URI[sha256sum] = "c55f9c9dc10fb8bec397b399a0fdded53cc9a2d8e30891bb0d63724d25c37bef"

# rsync >= 3.5 configure aborts when libidn2 headers are missing;
# disable it explicitly as OE-Core master does (no idn PACKAGECONFIG)
EXTRA_OECONF:append = " --disable-idn"

# remove out-of-date patch
SRC_URI:remove = " \
        file://0001-Turn-on-pedantic-errors-at-the-end-of-configure.patch \
        "
