SUMMARY = "Debugging tools"
inherit packagegroup

PR = "r1"

PACKAGES = "${PN}"

RDEPENDS_${PN} = "\
    strace \
    "
