SUMMARY = "Rsyslog is an enhanced multi-threaded syslogd"
DESCRIPTION = "\
 Rsyslog is an enhanced syslogd supporting, among others, MySQL,\
 PostgreSQL, failover log destinations, syslog/tcp, fine grain\
 output format control, high precision timestamps, queued operations\
 and the ability to filter on any message part. It is quite\
 compatible to stock sysklogd and can be used as a drop-in replacement.\
 Its advanced features make it suitable for enterprise-class,\
 encryption protected syslog relay chains while at the same time being\
 very easy to setup for the novice user."

DEPENDS = "zlib libestr libfastjson bison-native"
HOMEPAGE = "http://www.rsyslog.com/"
LICENSE = "GPLv3 & LGPLv3 & Apache-2.0"
LIC_FILES_CHKSUM = "file://COPYING;md5=51d9635e646fb75e1b74c074f788e973"

SRC_URI = "file://${BPN}/${BP}.tar.gz \
           file://${BPN}/rsyslog-8.24.0-ensure-parent-dir-exists-when-writting-log-file.patch \
           file://${BPN}/bugfix-rsyslog-7.4.7-imjournal-add-monotonic-timestamp.patch \
           file://${BPN}/bugfix-rsyslog-7.4.7-add-configuration-to-avoid-memory-leak.patch \
           file://${BPN}/rsyslog-8.24.0-set-permission-of-syslogd-dot-pid-to-0644.patch \
           file://${BPN}/rsyslog-8.37.0-initialize-variables-and-check-return-value.patch \
           file://initscript \
           file://rsyslog.conf \
           file://rsyslog.logrotate \
"
UPSTREAM_CHECK_URI = "https://github.com/rsyslog/rsyslog/releases"
UPSTREAM_CHECK_REGEX = "(?P<pver>\d+(\.\d+)+)"

inherit autotools pkgconfig

#not enable --enable-libsystemd configuration options
EXTRA_OECONF += "--disable-generate-man-pages ap_cv_atomic_builtins=yes --enable-libsystemd=no"
EXTRA_OECONF_remove_mipsarch = "ap_cv_atomic_builtins=yes"
EXTRA_OECONF_remove_powerpc = "ap_cv_atomic_builtins=yes"
EXTRA_OECONF_remove_riscv32 = "ap_cv_atomic_builtins=yes"
CFLAGS += " -I${RECIPE_SYSROOT}/usr/include/libfastjson/ "
# first line is default yes in configure
PACKAGECONFIG ??= " \
    rsyslogd rsyslogrt klog inet regexp uuid \
    fmhttp imdiag imfile \
    ${@bb.utils.filter('DISTRO_FEATURES', 'snmp', d)} \
"
RSYSLOG_IMAGE_NAME = "${MACHINE_ARCH}${RTOS_KERNEL_TAG}"
PACKAGECONFIG_remove += "${@bb.utils.contains('RSYSLOG_IMAGE_NAME', 'arm32a15eb-5.10', 'fmhttp', '', d)}"
PACKAGECONFIG_remove += "${@bb.utils.contains('RSYSLOG_IMAGE_NAME', 'arm32a9eb-5.10', 'fmhttp', '', d)}"
PACKAGECONFIG_remove += "${@bb.utils.contains('RSYSLOG_IMAGE_NAME', 'arm32a9eb-tiny-5.10', 'fmhttp', '', d)}"
PACKAGECONFIG_remove += "${@bb.utils.contains('RSYSLOG_IMAGE_NAME', 'arm64eb-5.10', 'fmhttp', '', d)}"
PACKAGECONFIG_remove += "${@bb.utils.contains('RSYSLOG_IMAGE_NAME', 'arm64el-5.10', 'fmhttp', '', d)}"
PACKAGECONFIG_remove += "${@bb.utils.contains('RSYSLOG_IMAGE_NAME', 'arm32a7el-preempt-5.10', 'fmhttp', '', d)}"

# add imfile module to support file monitor function
PACKAGECONFIG_append_arm64el = "${@bb.utils.contains('RTOS_TAG', '-preempt', 'imfile', '', d)}"

# default yes in configure
PACKAGECONFIG[relp] = "--enable-relp,--disable-relp,librelp,"
PACKAGECONFIG[rsyslogd] = "--enable-rsyslogd,--disable-rsyslogd,,"
PACKAGECONFIG[rsyslogrt] = "--enable-rsyslogrt,--disable-rsyslogrt,,"
PACKAGECONFIG[fmhttp] = "--enable-fmhttp,--disable-fmhttp,curl,"
PACKAGECONFIG[inet] = "--enable-inet,--disable-inet,,"
PACKAGECONFIG[klog] = "--enable-klog,--disable-klog,,"
PACKAGECONFIG[regexp] = "--enable-regexp,--disable-regexp,,"
PACKAGECONFIG[uuid] = "--enable-uuid,--disable-uuid,util-linux,"
PACKAGECONFIG[libgcrypt] = "--enable-libgcrypt,--disable-libgcrypt,libgcrypt,"
PACKAGECONFIG[testbench] = "--enable-testbench --enable-omstdout,--disable-testbench --disable-omstdout,,"

# default no in configure
PACKAGECONFIG[debug] = "--enable-debug,--disable-debug,,"
PACKAGECONFIG[imdiag] = "--enable-imdiag,--disable-imdiag,,"
PACKAGECONFIG[imfile] = "--enable-imfile,--disable-imfile,,"
PACKAGECONFIG[snmp] = "--enable-snmp,--disable-snmp,net-snmp,"
PACKAGECONFIG[gnutls] = "--enable-gnutls,--disable-gnutls,gnutls,"
PACKAGECONFIG[imjournal] = "--enable-imjournal,--disable-imjournal,"
PACKAGECONFIG[mmjsonparse] = "--enable-mmjsonparse,--disable-mmjsonparse,"
PACKAGECONFIG[mysql] = "--enable-mysql,--disable-mysql,mysql5,"
PACKAGECONFIG[postgresql] = "--enable-pgsql,--disable-pgsql,postgresql,"
PACKAGECONFIG[libdbi] = "--enable-libdbi,--disable-libdbi,libdbi,"
PACKAGECONFIG[mail] = "--enable-mail,--disable-mail,,"
PACKAGECONFIG[valgrind] = "--enable-valgrind,--disable-valgrind,valgrind,"
do_install_append() {
    install -d "${D}${sysconfdir}/init.d"
    install -d "${D}${sysconfdir}/logrotate.d"
    install -d "${D}/var/lib/rsyslog"
    install -m 750 ${WORKDIR}/initscript ${D}${sysconfdir}/init.d/syslog
    install -m 644 ${WORKDIR}/rsyslog.conf ${D}${sysconfdir}/rsyslog.conf
    install -m 644 ${WORKDIR}/rsyslog.logrotate ${D}${sysconfdir}/logrotate.d/logrotate.rsyslog
    sed -i -e "s#@BINDIR@#${bindir}#g" ${D}${sysconfdir}/logrotate.d/logrotate.rsyslog

    if ${@bb.utils.contains('PACKAGECONFIG', 'imjournal', 'true', 'false', d)}; then
        install -d 0755 ${D}${sysconfdir}/rsyslog.d
        echo '$ModLoad imjournal' >> ${D}${sysconfdir}/rsyslog.d/imjournal.conf
    fi
    if ${@bb.utils.contains('PACKAGECONFIG', 'mmjsonparse', 'true', 'false', d)}; then
        install -d 0755 ${D}${sysconfdir}/rsyslog.d
        echo '$ModLoad mmjsonparse' >> ${D}${sysconfdir}/rsyslog.d/mmjsonparse.conf
    fi
}

FILES_${PN} += "${bindir}"

INITSCRIPT_NAME = "syslog"
INITSCRIPT_PARAMS = "defaults"

CONFFILES_${PN} = "${sysconfdir}/rsyslog.conf"

RCONFLICTS_${PN} = "busybox-syslog sysklogd syslog-ng"

RDEPENDS_${PN} += "logrotate"
