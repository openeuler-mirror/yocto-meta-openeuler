
PV = "1.6.40"

# patch in openEuler
# build error: libpng-fix-arm-neon.patch
SRC_URI:prepend = "file://${BP}.tar.gz \
           file://libpng-multilib.patch \
"
