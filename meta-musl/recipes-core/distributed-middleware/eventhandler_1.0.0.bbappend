#fix musl libc error about strerror_r
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

require distributed-build-musl.inc

SRC_URI:append = " \
        file://0001-fix-eventhandler-strerror_r-error-musl.patch;patchdir=${WORKDIR}/${pkg-eventhandler} \
"

