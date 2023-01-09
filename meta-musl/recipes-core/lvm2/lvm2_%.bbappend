FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"
DEPENDS_append ="\
  gcompat \
"
LDFLAGS_append = " -lgcompat"
# add patch to support musl
SRC_URI_append =" \
    file://lvmcmdline.patch \
    file://add_header.patch \
    file://use_lgcompat.patch \
"
