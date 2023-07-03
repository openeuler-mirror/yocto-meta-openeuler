SUMMARY = "packagegroup of dsoftbus"
PR = "r1"
inherit packagegroup

RDEPENDS:packagegroup-dsoftbus = " \
"

RDEPENDS:packagegroup-dsoftbus:append:aarch64 = " \
dsoftbus \
"
