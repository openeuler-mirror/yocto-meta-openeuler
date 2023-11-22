# main bb file: yocto-poky/meta/recipes-support/icu/icu_68.2.bb
OPENEULER_SRC_URI_REMOVE = "https http git"

PV = "72.1"

LIC_FILES_CHKSUM = "file://../LICENSE;md5=a89d03060ff9c46552434dbd1fe3ed1f"

SRC_URI_prepend = "file://${BPN}4c-${ICU_PV}-src.tgz \
           file://gennorm2-man.patch;striplevel=2 \
           file://icuinfo-man.patch;striplevel=2 \
           file://backport-remove-TestJitterbug6175.patch;striplevel=2 \
           file://delete-taboo-words.patch \
           "
