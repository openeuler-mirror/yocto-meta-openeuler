SUMMARY = "preempt-rt packages"
DESCRIPTION = "packages related to preempt-rt, such rt-tests, hwlatdetect and other tools"

inherit packagegroup

PR = "r1"

PACKAGES = "${PN}"

RDEPENDS:${PN} = " \
    rt-tests \
    hwlatdetect \
"
