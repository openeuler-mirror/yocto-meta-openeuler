# main bbfile: meta-oe/recipes-extended/rsyslog/rsyslog_8.2102.0.bb?h=hardknott

FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

# version in openEuler
PV = "8.2110.0"

# files, patches that come from openeuler
SRC_URI =+ " \
        file://rsyslog-8.24.0-ensure-parent-dir-exists-when-writting-log-file.patch \
        file://bugfix-rsyslog-7.4.7-imjournal-add-monotonic-timestamp.patch \
        file://bugfix-rsyslog-7.4.7-add-configuration-to-avoid-memory-leak.patch \
        file://rsyslog-8.37.0-initialize-variables-and-check-return-value.patch \
        file://bugfix-CVE-2022-24903.patch \
        file://backport-testbench-skip-omfwd_fast_imuxsock.sh-if-liblogging-stdlog-is-not-available.patch \
        file://backport-Fixes-4395-by-correctly-checking-for-EPIPE.patch \
        file://backport-rsyslogd-adjust-the-order-of-doHUP-and-processImInte.patch \
        file://backport-gnutls-bugfix-Fix-error-handling-in-gtlsRecordRecv.patch \
        file://backport-Fix-non-null-terminated-string-used-with-strlen.patch \
        file://backport-tcpsrv-do-not-decrease-number-of-to-be-processed-fds.patch \
        file://backport-imptcp-bugfix-worker-thread-starvation-on-extreme-tr.patch \
        file://backport-Fix-memory-leak-when-globally-de-initialize-GnuTLS.patch \
        file://backport-Fix-memory-leak-when-free-action-worker-data-table.patch  \
"

SRC_URI[md5sum] = "2d2b9d4a70a6e2fd4a7e806a5782c56b"
SRC_URI[sha256sum] = "3f904ec137ca6412e8273f7896d962ecb589f7d0c589bdf16b1709ec27e24f31"

# according to openEuler, no need to use liblogging libgcrypt
DEPENDS_remove = "liblogging"
PACKAGECONFIG_remove = "libgcrypt"
