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

# new version alter
PACKAGECONFIG:remove = "gnutls"
PACKAGECONFIG:append = " openssl"

PACKAGECONFIG[openssl] = "--enable-openssl,--disable-openssl,openssl,"
# For libcap-ng, see commit log and  https://github.com/rsyslog/rsyslog/issues/5091
PACKAGECONFIG[libcap-ng] = "--enable-libcap-ng,--disable-libcap-ng,libcap-ng,"

PACKAGECONFIG[systemd] = "--enable-libsystemd,--disable-libsystemd,systemd,"
