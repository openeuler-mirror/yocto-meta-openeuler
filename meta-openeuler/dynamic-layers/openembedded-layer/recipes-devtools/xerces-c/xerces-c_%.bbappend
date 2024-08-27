# main bbfile: yocto-meta-openembedded/meta-oe/recipes-devtools/xerces-c/xerces-c_3.1.4.bb

# version in openEuler
# We have to use 3.2.4+ version because in 3.2.4 version it
# contains the fix of "cross-compiling failed" bug
PV = "3.2.5"
S = "${WORKDIR}/${BP}"

# files, patches that come from openeuler
SRC_URI:prepend = " \
    file://${BP}.tar.gz \
"

# In the poky's bb file, the lib is 3.1.so
# However, now we are using 3.2.4
FILES:libxerces-c = "${libdir}/libxerces-c-3.2.so"

SRC_URI[md5sum] = "dc8241095f223e7d6f8c42d974bdd272"
SRC_URI[sha256sum] = "545cfcce6c4e755207bd1f27e319241e50e37c0c27250f11cda116018f1ef0f5"
