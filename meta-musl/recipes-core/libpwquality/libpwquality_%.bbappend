DEPENDS_append ="\
  gcompat \
"
LDFLAGS_append = " -lgcompat"

#add patch to support musl
FILESEXTRAPATHS_prepend := "${THISDIR}/libpwquality/:"
SRC_URI_append = " \
          file://libpwquality-musl.patch \
"
