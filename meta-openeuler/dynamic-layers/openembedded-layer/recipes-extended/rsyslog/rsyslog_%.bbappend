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
        file://backport-fix-memory-leak-in-omazureeventhubs-on-accepted-PN_D.patch \
        file://tls-bugfix-parameter-StreamDriver_CRLFile-not-known.patch \
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

# in openeuler rsyslog's repo, there are rsyslog.conf and rsyslog.service which
# will conflict with the rsyslog.conf and rsyslog.service in openembedded's rsyslog
# recipe. Here we use a trick to use openembedded's rsyslog config files.
do_install:prepend() {
    # remove openeuler's config files as they have higher priority
    rm ${WORKDIR}/rsyslog.conf
    rm ${WORKDIR}/rsyslog.service
    # use openembedded's config files
    cp ${FILE_DIRNAME}/rsyslog/rsyslog.conf ${WORKDIR}
    cp ${FILE_DIRNAME}/rsyslog/rsyslog.service ${WORKDIR}
}

PACKAGECONFIG[openssl] = "--enable-openssl,--disable-openssl,openssl,"
# For libcap-ng, see commit log and  https://github.com/rsyslog/rsyslog/issues/5091
PACKAGECONFIG[libcap-ng] = "--enable-libcap-ng,--disable-libcap-ng,libcap-ng,"

PACKAGECONFIG[systemd] = "--enable-libsystemd,--disable-libsystemd,systemd,"

# the syslog starting need workDirectory with /var/lib/rsyslog
do_install:append(){
        mkdir -p ${D}/var/lib/rsyslog
}
