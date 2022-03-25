SUMMARY = "dsoftbus"
DESCRIPTION = "dsoftbus"
PR = "r1"
LICENSE = "CLOSED"

inherit bin_package

SRC_URI = "file://dsoftbus_output"

S = "${WORKDIR}/dsoftbus_output"

FILES_${PN}-dev = "${includedir}"
FILES_${PN} = "${libdir} ${bindir}"
INSANE_SKIP_${PN} += "already-stripped"
