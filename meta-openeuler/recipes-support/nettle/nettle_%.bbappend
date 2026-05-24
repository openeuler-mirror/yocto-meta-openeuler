# main bbfile: yocto-poky/meta/recipes-support/nettle/nettle_3.7.2.bb

# version in openEuler
PV = "3.8.1"

# files, patches that come from openeuler
# Remove remote URL (sha256 in base recipe is for a different version)
SRC_URI:remove = "${GNU_MIRROR}/${BPN}/${BP}.tar.gz"

SRC_URI += " \
        file://${BP}.tar.gz \
"

# upstream patches that don't apply to openEuler 3.8.1 source
# (from base recipe nettle_3.9.1.bb)
SRC_URI:remove = "file://Add-target-to-only-build-tests-not-run-them.patch \
    file://check-header-files-of-openssl-only-if-enable_.patch \
"

# from 3.8.1.bb
EXTRA_OECONF:append:armv7a = "${@bb.utils.contains(\"TUNE_FEATURES\",\"neon\",\"\",\" --disable-arm-neon --disable-fat\",d)}"
EXTRA_OECONF:append:armv7ve = "${@bb.utils.contains(\"TUNE_FEATURES\",\"neon\",\"\",\" --disable-arm-neon --disable-fat\",d)}"
