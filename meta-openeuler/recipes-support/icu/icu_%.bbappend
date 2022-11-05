# main bb file: yocto-poky/meta/recipes-support/icu/icu_68.2.bb

PV = "69.1"

SRC_URI_remove = "${BASE_SRC_URI};name=code \
           ${DATA_SRC_URI};name=data \
                  "

SRC_URI_prepend = "file://${BPN}4c-69_1-src.tgz \
                   file://gennorm2-man.patch;striplevel=2 \
                   file://icuinfo-man.patch;striplevel=2 \
                   file://backport-remove-TestJitterbug6175.patch;striplevel=2 \
                   "

SRC_URI[md5sum] = "9403db682507369d0f60a25ea67014c4"
SRC_URI[sha256sum] = "4cba7b7acd1d3c42c44bb0c14be6637098c7faf2b330ce876bc5f3b915d09745"
