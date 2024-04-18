# main bb file: yocto-poky/meta/recipes-support/icu/icu_68.2.bb

PV = "74.1"

LIC_FILES_CHKSUM = "file://../LICENSE;md5=08dc3852df8fffa807301902ad899ff8"

SRC_URI:prepend = " \
    file://${BPN}4c-${ICU_PV}-src.tgz \
    file://gennorm2-man.patch;striplevel=2 \
    file://icuinfo-man.patch;striplevel=2 \
    file://backport-remove-TestJitterbug6175.patch;striplevel=2 \
"

# the patch delete-taboo-words.patch apply failed

SRC_URI[sha256sum] = "818a80712ed3caacd9b652305e01afc7fa167e6f2e94996da44b90c2ab604ce1"

# The following part is for building icu with version 74.1
# ==============================================================

DEPENDS:class-native = ""

DEPENDS:remove = "autoconf-archive"
DEPENDS:append = " autoconf-archive-native"

# EXTRA_OECONF = "--with-cross-build=${STAGING_ICU_DIR_NATIVE} --disable-icu-config"
# EXTRA_OECONF:class-native = "--disable-icu-config"
# EXTRA_OECONF:class-nativesdk = "--with-cross-build=${STAGING_ICU_DIR_NATIVE} --disable-icu-config"
