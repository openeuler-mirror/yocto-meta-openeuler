# main bbfile: yocto-meta-openembedded/meta-oe/recipes-devtools/xerces-c/xerces-c_3.1.4.bb

# version in openEuler
# We have to use 3.2.4+ version because in 3.2.4 version it
# contains the fix of "cross-compiling failed" bug
PV = "3.2.4"
S = "${WORKDIR}/${BP}"

# files, patches that come from openeuler
SRC_URI:prepend = " \
    file://${BP}.tar.gz \
    file://CVE-2018-1311.patch \
"

# In the poky's bb file, the lib is 3.1.so
# However, now we are using 3.2.4
FILES:libxerces-c = "${libdir}/libxerces-c-3.2.so"

SRC_URI[md5sum] = "0f6b55a00a6dedb3f032f3be14898695"
SRC_URI[sha256sum] = "705582a1956971c03ffdb014a8707d3eb9afcd51fe6e53cfcc98be70a96fb726"
