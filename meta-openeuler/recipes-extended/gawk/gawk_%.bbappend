# main bbfile: yocto-poky/meta/recipes-extended/gawk/gawk_5.1.0.bb

# version in openEuler
PV = "5.3.0"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI:remove = " \
            file://remove-sensitive-tests.patch \
"

# files, patches that come from openeuler.
# The following three patches exist in spec file, but not in the source code respository:
# file://Disable-racy-test-in-test-iolint.awk.patch
# file://Restore-removed-test-in-test-iolint.awk.patch
# file://Reorder-statements-in-iolint-to-try-to-eliminate-a-r.patch
SRC_URI:prepend = " \
           file://${BP}.tar.xz \
           file://Disable-pma-test.awk.patch \
           "

SRC_URI[md5sum] = "2f724d925873fc82f5e7b1d605ba9a42"
SRC_URI[sha256sum] = "e4ddbad1c2ef10e8e815ca80208d0162d4c983e6cca16f925e8418632d639018"

# backup from meta/recipes-extended/gawk/gawk_5.3.0.bb
PACKAGES =+ "${PN}-gawkbug"
FILES:${PN}-gawkbug += "${bindir}/gawkbug"
do_install:append() {
	# Strip non-reproducible build flags (containing build paths)
	sed -i -e 's|^CC.*|CC=""|g' -e 's|^CFLAGS.*|CFLAGS=""|g' ${D}${bindir}/gawkbug
}
