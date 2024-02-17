# main bbfile: meta-oe/recipes-graphics/tslib/tslib_1.22.bb

PV = "1.16"

SRC_URI:prepend = "file://${BP}.tar.bz2 \
"

S = "${WORKDIR}/${BP}"

PACKAGECONFIG[evthres] = ""
PACKAGECONFIG[one-wire-ts-input] = ""
PACKAGECONFIG:remove = "evthres"

SRC_URI[md5sum] = "22adf05cb3f828889bbb329a505b3847"
SRC_URI[sha256sum] = "15bf44035a05a8ce4f7b0686cf5e989492fda3a1fcd8b3ad9e850db1fcd51928"