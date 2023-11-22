# main bbfile: yocto-poky/meta/recipes-extended/gawk/gawk_5.1.0.bb

# version in openEuler
PV = "5.1.1"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = "${GNU_MIRROR}/gawk/gawk-${PV}.tar.gz \
"

# files, patches that come from openeuler
SRC_URI_prepend = " \
           file://${BP}.tar.xz \
           file://Disable-racy-test-in-test-iolint.awk.patch \
           file://Restore-removed-test-in-test-iolint.awk.patch \
           file://Reorder-statements-in-iolint-to-try-to-eliminate-a-r.patch \
           file://backport-CVE-2023-4156.patch \
           "
