SUMMARY = "openEuler Embedded dynamic message of the day"
DESCRIPTION = "Generate /run/motd with runtime system information at every \
boot. /etc/motd (from base-files) is a symlink to /run/motd, so sshd and \
login show fresh system info after login without any PAM or sshd \
configuration change. Supports both systemd and sysvinit."

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://openeuler-motd.sh \
    file://openeuler-motd.service \
    file://openeuler-motd.init \
"

S = "${WORKDIR}"

inherit ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd', '', d)} update-rc.d

SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_SERVICE:${PN} = "openeuler-motd.service"
SYSTEMD_AUTO_ENABLE = "enable"

INITSCRIPT_NAME = "openeuler-motd"
INITSCRIPT_PARAMS = "defaults 90"

# /etc/motd is provided by base-files as a symlink to /run/motd
RDEPENDS:${PN} = "base-files"

do_install() {
    install -d ${D}${libexecdir}
    install -m 0755 ${WORKDIR}/openeuler-motd.sh ${D}${libexecdir}/openeuler-motd.sh

    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -d ${D}${systemd_system_unitdir}
        sed -e 's|@LIBEXECDIR@|${libexecdir}|g' \
            ${WORKDIR}/openeuler-motd.service > \
            ${D}${systemd_system_unitdir}/openeuler-motd.service
    fi

    if ${@bb.utils.contains('DISTRO_FEATURES', 'sysvinit', 'true', 'false', d)}; then
        install -d ${D}${sysconfdir}/init.d
        install -m 0755 ${WORKDIR}/openeuler-motd.init \
                ${D}${sysconfdir}/init.d/openeuler-motd
    fi
}

FILES:${PN} = " \
    ${libexecdir}/openeuler-motd.sh \
    ${systemd_system_unitdir}/openeuler-motd.service \
    ${sysconfdir}/init.d/openeuler-motd \
"
