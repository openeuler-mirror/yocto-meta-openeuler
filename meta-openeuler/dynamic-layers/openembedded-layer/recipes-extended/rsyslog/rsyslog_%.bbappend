# main bbfile: meta-oe/recipes-extended/rsyslog/rsyslog_8.2102.0.bb?h=hardknott

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

# version in openEuler
PV = "8.2312.0"

# files, patches that come from openeuler
SRC_URI =+ " \
        file://${BP}.tar.gz \
        file://rsyslog-8.24.0-ensure-parent-dir-exists-when-writting-log-file.patch \
        file://bugfix-rsyslog-7.4.7-imjournal-add-monotonic-timestamp.patch \
        file://bugfix-rsyslog-7.4.7-add-configuration-to-avoid-memory-leak.patch \
        file://rsyslog-8.37.0-initialize-variables-and-check-return-value.patch \
        file://print-main-queue-info-to-journal-when-queue-full.patch \
        file://print-main-queue-info-to-journal-when-receive-USR1-signal.patch \
        file://backport-outchannel-eleminate-type-cast-for-compatibility-rea.patch \
        file://backport-fix-printing-of-time_t-values.patch \
        file://backport-omfile-do-not-carry-out-actual-action-when-writing-to-dev-null.patch \
        file://tls-bugfix-parameter-StreamDriver_CRLFile-not-known.patch \
        file://backport-fix-memory-leak-in-omazureeventhubs-on-accepted-PN_D.patch \
        file://backport-Fix-passing-the-value-to-EscapeChar.patch \
        file://backport-Do-not-free-the-uninitialized-cstring.patch \
        file://backport-Keep-original-free-pattern.patch \
        file://backport-network-subsystem-improve-connection-failure-error-m.patch \
        file://backport-Fix-runConf-NULL-pointer-refence.patch \
        file://backport-rainerscript-do-not-try-to-call-a-function-if-it-doe.patch \
        file://backport-nsd_ptcp-regression-fix-remove-debugging-messages-em.patch \
        file://backport-Fix-legacy-ActionQueueDiscardMark-parameter.patch \
        file://backport-0001-gnutls-bugfix-Avoid-blocking-sockets-during-TLS-hand.patch \
        file://backport-0002-gnutls-bugfix-Add-timeout-to-GnuTLS-handshake.patch \
        file://backport-0003-core-fix-potential-NULL-ptr-access-on-HUP-in-very-ea.patch \
        file://backport-0004-omfwd-fix-segfault-in-UDP-freeaddrinfo.patch \
        file://backport-0005-gnutls-TLS-driver-fix-small-memory-leak.patch \
        file://backport-0006-rsyslog-startup-bugfix-cosmetic-memory-leak.patch \
        file://backport-0007-core-fix-potential-misadressing-in-sigmask.patch \
        file://backport-0008-covscan-remove-defect-type-of-RESOURCE_LEAK.patch \
        file://backport-0009-Fix-a-buffer-overflow-when-the-argument-to-replace-i.patch \
        file://backport-imuxsock-Add-statistics-counter-for-discarded-messag.patch \
        file://backport-omjournal-Fix-priority-value.patch \
        file://backport-fix-stringop-overread-warning-in-omusrmsg.patch \
        file://backport-fix-hashtable-realloc-memset-range.patch \
        file://backport-fix-off-by-one-buffer-overflow.patch \
        file://backport-imjournal-fix-double-sd_journal_close-during-thread.patch \
        file://backport-omusrmsg-bugfix-potential-double-free-which-can-cause.patch \
        file://backport-omusrmsg-bugfix-potential-null-pointer-dereference-c.patch \
        file://backport-imjournal-fix-vulnerability-in-state-file-creation.patch \
        file://backport-imjournal-initialize-instance-fields-to-avoid-invali.patch \
        file://backport-omusrmsg-guard-empty-systemd-session-lists.patch \
        file://backport-fix-CVE-2026-19654-imtcp-guard-regex-framing-match-at-line-start.patch \
        file://backport-fix-CVE-2026-78002-rainerscript-align-replace-sizing-rewind.patch \
        file://backport-fix-CVE-2026-78002-tests-cover-overlapping-replace-sizing.patch \
"

# file://0001-tests-disable-the-check-for-inotify.patch

SRC_URI:append:libc-musl = " \
        file://disable-omfile-outchannel.patch \     
"

SRC_URI[md5sum] = "632381aead68840967c74fbb564436cc"
SRC_URI[sha256sum] = "774032006128a896437f5913e132aa27dbfb937cd8847e449522d5a12d63d03e"

# according to openEuler, no need to use liblogging libgcrypt
DEPENDS:remove = "liblogging"
PACKAGECONFIG:remove = "libgcrypt"

# new version uses openssl
PACKAGECONFIG:remove = "gnutls"
PACKAGECONFIG:append = " openssl"

PACKAGECONFIG[openssl] = "--enable-openssl,--disable-openssl,openssl,"
# For libcap-ng, see commit log and  https://github.com/rsyslog/rsyslog/issues/5091
PACKAGECONFIG[libcap-ng] = "--enable-libcap-ng,--disable-libcap-ng,libcap-ng,"

PACKAGECONFIG[systemd] = "--enable-libsystemd,--disable-libsystemd,systemd,"
