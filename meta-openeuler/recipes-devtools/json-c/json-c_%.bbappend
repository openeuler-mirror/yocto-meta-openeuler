# main bbfile: yocto-poky/meta/recipes-devtools/json-c/json-c_0.15.bb

# json-c version in openEuler
PV = "0.15-20200726"

# apply patch
SRC_URI += "file://${BPN}/backport-json-escape-str-avoid-harmless-unsigned-integer-overflow.patch"

SRC_URI[md5sum] = "b3841c9abdca837ea00ce6a5ada4bb2c"
SRC_URI[sha256sum] = "4ba9a090a42cf1e12b84c64e4464bb6fb893666841d5843cc5bef90774028882"

S = "${WORKDIR}/json-c-json-c-0.15-20200726"
