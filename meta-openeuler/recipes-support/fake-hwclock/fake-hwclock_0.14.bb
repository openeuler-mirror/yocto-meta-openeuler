SUMMARY = "Save/restore system clock on machines without working RTC hardware"
DESCRIPTION = "fake-hwclock is a simple set of scripts to save the kernel's \
current clock periodically (including at shutdown) and restore it at boot, so \
that the system has a reasonable time value even on machines that lack a \
working battery-backed real-time clock (RTC). Using NTP is still recommended \
to obtain real time synchronisation once the system is up."
HOMEPAGE = "https://git.einval.com/cgi-bin/gitweb.cgi?p=fake-hwclock.git"
SECTION = "base"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=0636e73ff0215e8d672dc4c32c317bb3"

inherit oee-archive systemd

PV = "0.14"
SRC_URI = "file://${BP}.tar.gz"

SRC_URI[md5sum] = "15942b0a5625e4c1034387a2d3119421"
SRC_URI[sha256sum] = "e186aef41fdb4967a2bab85503a3110efdf000280093d32d48b405a5a815af81"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${sbindir}
    install -m 0755 ${S}/fake-hwclock ${D}${sbindir}/fake-hwclock

    install -d ${D}${sysconfdir}/default
    install -m 0644 ${S}/etc/default/fake-hwclock ${D}${sysconfdir}/default/fake-hwclock

    install -d ${D}${mandir}/man8
    install -m 0644 ${S}/fake-hwclock.8 ${D}${mandir}/man8/fake-hwclock.8

    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -d ${D}${systemd_system_unitdir}
        install -m 0644 ${S}/debian/fake-hwclock-load.service \
                        ${D}${systemd_system_unitdir}/fake-hwclock-load.service
        install -m 0644 ${S}/debian/fake-hwclock-save.service \
                        ${D}${systemd_system_unitdir}/fake-hwclock-save.service
        install -m 0644 ${S}/debian/fake-hwclock-save.timer \
                        ${D}${systemd_system_unitdir}/fake-hwclock-save.timer
    else
        install -d ${D}${sysconfdir}/cron.hourly
        install -m 0755 ${S}/debian/fake-hwclock.cron.hourly \
                        ${D}${sysconfdir}/cron.hourly/fake-hwclock
    fi
}

SYSTEMD_SERVICE:${PN} = "fake-hwclock-load.service fake-hwclock-save.service fake-hwclock-save.timer"

CONFFILES:${PN} = "${sysconfdir}/default/fake-hwclock"

FILES:${PN} += " \
    ${sbindir}/fake-hwclock \
    ${sysconfdir}/default/fake-hwclock \
"

RDEPENDS:${PN} += "coreutils"
