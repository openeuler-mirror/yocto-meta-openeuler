PV = "1.6.3"

SRC_URI[sha256sum] = "3f72c68db30971ebbf14367527719423f0a4d5f8103fc9f4a1c01a9fa440de5c"

# the patch ksba-add-pkgconfig-support.patch will result in error
SRC_URI:remove = "file://ksba-add-pkgconfig-support.patch \
"
