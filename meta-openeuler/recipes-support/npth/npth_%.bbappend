PV = "1.6"
S = "${WORKDIR}/npth-${PV}"
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:remove = " \
        ${GNUPG_MIRROR}/npth/npth-${PV}.tar.bz2 \
"

SRC_URI:append = " \
        file://npth-${PV}.tar.bz2 \
        file://backport-0001-w32-Use-cast-by-uintptr_t-for-thread-ID.patch \
        file://add-test-cases.patch \
        file://backport-0002-posix-Add-npth_poll-npth_ppoll.patch \
 "

