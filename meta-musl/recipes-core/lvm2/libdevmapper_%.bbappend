FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"
DEPENDS:append ="\
  gcompat \
"
LDFLAGS:append = " -lgcompat"
# add patch to support musl
SRC_URI:append =" \
    file://add_header.patch \
    file://use_lgcompat.patch \
"
