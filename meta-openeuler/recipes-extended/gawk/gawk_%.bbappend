# main bbfile: yocto-poky/meta/recipes-extended/gawk/gawk_5.1.0.bb

# version in openEuler
PV = "5.1.1"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
        ${GNU_MIRROR}/gawk/gawk-${PV}.tar.gz \
"

# files, patches that come from openeuler
# Reorder-statements-in-iolint-to-try-to-eliminate-a-r.patch fails to apply
SRC_URI += " \
        file://${BP}.tar.xz;name=tarball \
        file://Disable-racy-test-in-test-iolint.awk.patch \
        file://Restore-removed-test-in-test-iolint.awk.patch \
"

SRC_URI[tarball.md5sum] = "83650aa943ff2fd519b2abedf8506ace"
SRC_URI[tarball.sha256sum] = "d87629386e894bbea11a5e00515fc909dc9b7249529dad9e6a3a2c77085f7ea2"
