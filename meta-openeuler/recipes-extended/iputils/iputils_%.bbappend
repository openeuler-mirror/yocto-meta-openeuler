# bbfile: yocto-meta-openeuler/meta-openeuler/recipes-extended/iputils/iputils_20221126.bb

SRC_URI = "file://iputils-${PV}.tar.gz \
        file://revert-process-interrupts-in-ping-_receive_error_msg.patch \
        file://arping-Fix-exit-code-on-w-option.patch \
        file://backport-clockdiff-Set-ppoll-timeout-minimum-to-1ms.patch \
        file://backport-ping-fix-overflow-on-negative.patch \
        file://backport-tracepath-Restore-the-MTU-probing-behavior.patch \
        file://backport-tracepath-Merge-if-clauses.patch \
        file://backport-ping-Fix-the-errno-handling-for-strtod.patch \
        file://backport-ping-Remove-duplicate-include.patch \
        file://backport-ping6-Fix-support-for-DSCP.patch \
        file://backport-Revert-ping-use-random-value-for-the-identifier-field.patch \
        file://backport-ping-Handle-interval-correctly-in-the-second-after-booting.patch \
        file://backport-tracepath-Dont-assume-tv_sec-0-means-unset.patch \
        file://backport-ping-check-return-value-of-write-to-avoid-integer-overflow.patch \
        file://backport-ping-fix-IPv4-checksum-check-always-succeeding-once-again.patch \
        file://backport-CVE-2025-47268.patch \
        file://backport-CVE-2025-48964.patch \
"

S = "${WORKDIR}/iputils-${PV}"

ASSUME_PROVIDE_PKGS = "iputils"
