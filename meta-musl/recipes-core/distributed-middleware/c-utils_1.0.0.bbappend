#fix musl libc error about add header limits.h
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

require distributed-build-musl.inc

SRC_URI += " \
            file://0001-add-header-limits.patch;patchdir=${WORKDIR}/${pkg-c-utils} \
            file://0002-add-TEMP_FAILURE_RETRY-definition-musl.patch;patchdir=${WORKDIR}/${pkg-c-utils} \
"
