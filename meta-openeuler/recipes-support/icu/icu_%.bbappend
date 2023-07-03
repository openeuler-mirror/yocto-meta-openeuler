# main bb file: yocto-poky/meta/recipes-support/icu/icu_68.2.bb
OPENEULER_SRC_URI_REMOVE = "https http git"

PV = "72.1"

LIC_FILES_CHKSUM = "file://../LICENSE;md5=a89d03060ff9c46552434dbd1fe3ed1f"

SRC_URI:prepend = " \
    file://${BPN}4c-${ICU_PV}-src.tgz \
    file://gennorm2-man.patch;striplevel=2 \
    file://icuinfo-man.patch;striplevel=2 \
    file://backport-remove-TestJitterbug6175.patch;striplevel=2 \
    file://0001-add-support-loongarch64.patch;striplevel=2 \
    file://icu-Add-sw64-architecture.patch;striplevel=2 \
"

SRC_URI[sha256sum] = "a2d2d38217092a7ed56635e34467f92f976b370e20182ad325edea6681a71d68"

# EXTRA_OECONF = "--with-cross-build=${STAGING_ICU_DIR_NATIVE} --disable-icu-config"
# EXTRA_OECONF:class-native = "--disable-icu-config"
# EXTRA_OECONF:class-nativesdk = "--with-cross-build=${STAGING_ICU_DIR_NATIVE} --disable-icu-config"
