OPENEULER_SRC_URI_REMOVE = "git"

PV = "0.25.0"

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}/:"

SRC_URI:prepend = "file://${BP}.tar.xz \
           file://backport-Fix-probing-of-C_GetInterface.patch \
           "

# patches from upstream, fix meson.build error
SRC_URI:append = " \
           file://strerror-1.patch \
           file://strerror-2.patch"

S = "${WORKDIR}/${BP}"

# keep same as upstream
BBCLASSEXTEND += " native"
