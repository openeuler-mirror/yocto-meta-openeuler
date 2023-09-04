# main bb file: yocto-poky/meta/recipes-support/icu/icu_68.2.bb

PV = "73.2"

LIC_FILES_CHKSUM = "file://../LICENSE;md5=80c2cf39ad8ae12b9b9482a1737c6650"

SRC_URI:remove := "${BASE_SRC_URI};name=code \
           ${DATA_SRC_URI};name=data \"

SRC_URI:prepend = " \
    file://${BPN}4c-${ICU_PV}-src.tgz \
    file://gennorm2-man.patch;striplevel=2 \
    file://icuinfo-man.patch;striplevel=2 \
    file://backport-remove-TestJitterbug6175.patch;striplevel=2 \
"

# the patch delete-taboo-words.patch apply failed

SRC_URI[sha256sum] = "818a80712ed3caacd9b652305e01afc7fa167e6f2e94996da44b90c2ab604ce1"

# EXTRA_OECONF = "--with-cross-build=${STAGING_ICU_DIR_NATIVE} --disable-icu-config"
# EXTRA_OECONF:class-native = "--disable-icu-config"
# EXTRA_OECONF:class-nativesdk = "--with-cross-build=${STAGING_ICU_DIR_NATIVE} --disable-icu-config"
