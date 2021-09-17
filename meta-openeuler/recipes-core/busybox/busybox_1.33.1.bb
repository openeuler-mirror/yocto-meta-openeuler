SUMMARY = "Dummy Linux kernel"
DESCRIPTION = "Dummy Linux kernel, to be selected as the preferred \
provider for virtual/kernel to satisfy dependencies for situations \
where you wish to build the kernel externally from the build system."
SECTION = "kernel"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

INHIBIT_DEFAULT_DEPS = "1"
PR = "r1"

DEPENDS += "virtual/libc"
#get arch info
inherit kernel-arch

SRC_URI = "file://busybox/busybox-1.33.1.tar.bz2 \
           file://yocto-embedded-tools/config/arm64/defconfig-busybox \
"
FILESPATH_prepend += "${LOCAL_FILES}/${BPN}:"
S = "${WORKDIR}/${BPN}-${PV}"

#not split debug files with dwarfsrcfiles,no dwarfsrcfiles
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"

# Whether to split the suid apps into a seperate binary
BUSYBOX_SPLIT_SUID ?= "1"

export EXTRA_CFLAGS = "${CFLAGS}"
export EXTRA_LDFLAGS = "${LDFLAGS}"

EXTRA_OEMAKE = "CC='${CC}' V=1 ARCH=${ARCH} CROSS_COMPILE=${TARGET_PREFIX} SKIP_STRIP=y HOSTCC='${BUILD_CC}' HOSTCPP='${BUILD_CPP}'"
#use host pkg-config add by openeuler
EXTRA_OECONF += "PKG_CONFIG=pkg-config"
EXTRA_OEMAKE += "PKG_CONFIG=pkg-config"

PACKAGES =+ "${PN}-linuxrc ${PN}-httpd ${PN}-udhcpd ${PN}-udhcpc ${PN}-syslog ${PN}-mdev ${PN}-hwclock"

FILES_${PN}-httpd = "${sysconfdir}/init.d/busybox-httpd /srv/www"
FILES_${PN}-syslog = "${sysconfdir}/init.d/syslog* ${sysconfdir}/syslog-startup.conf* ${sysconfdir}/syslog.conf* ${systemd_unitdir}/system/syslog.service ${sysconfdir}/default/busybox-syslog"
FILES_${PN}-mdev = "${sysconfdir}/init.d/mdev ${sysconfdir}/mdev.conf ${sysconfdir}/mdev/*"
FILES_${PN}-udhcpd = "${sysconfdir}/init.d/busybox-udhcpd"
FILES_${PN}-udhcpc = "${sysconfdir}/udhcpc.d ${datadir}/udhcpc"
FILES_${PN}-hwclock = "${sysconfdir}/init.d/hwclock.sh"
FILES_${PN}-linuxrc = "/linuxrc"

INITSCRIPT_PACKAGES = "${PN}-httpd ${PN}-syslog ${PN}-udhcpd ${PN}-mdev ${PN}-hwclock"

INITSCRIPT_NAME_${PN}-httpd = "busybox-httpd"
INITSCRIPT_NAME_${PN}-hwclock = "hwclock.sh"
INITSCRIPT_NAME_${PN}-mdev = "mdev"
INITSCRIPT_PARAMS_${PN}-mdev = "start 04 S ."
INITSCRIPT_NAME_${PN}-syslog = "syslog"
INITSCRIPT_NAME_${PN}-udhcpd = "busybox-udhcpd"
INITSCRIPT_NAME_${PN}-initrc = "initrc"

SYSTEMD_PACKAGES = "${PN}-syslog"
SYSTEMD_SERVICE_${PN}-syslog = "${@bb.utils.contains('SRC_URI', 'file://syslog.cfg', 'busybox-syslog.service', '', d)}"

RDEPENDS_${PN}-syslog = "busybox"
CONFFILES_${PN}-syslog = "${sysconfdir}/syslog-startup.conf"
RCONFLICTS_${PN}-syslog = "rsyslog sysklogd syslog-ng"

CONFFILES_${PN}-mdev = "${sysconfdir}/mdev.conf"

RRECOMMENDS_${PN} = "${PN}-udhcpc"

RDEPENDS_${PN} = "${@["", "busybox-inittab"][(d.getVar('VIRTUAL-RUNTIME_init_manager') == 'busybox')]}"

do_configure() {
        cp ../yocto-embedded-tools/config/arm64/defconfig-busybox .config
        set -e
        yes '' | oe_runmake oldconfig
}

do_compile () {
        export KCONFIG_NOTIMESTAMP=1
        if [ -e .config.orig ]; then
            # Need to guard again an interrupted do_compile - restore any backup
            cp .config.orig .config
        fi
        cp .config .config.orig

        for s in suid nosuid; do
            oe_runmake busybox_unstripped
            mv busybox_unstripped busybox.$s
            oe_runmake busybox.links
            sort busybox.links > busybox.links.$s
            rm busybox.links
        done
        cp .config.orig .config
}

do_install () {
        oe_runmake CONFIG_PREFIX="${D}" install
}
INSANE_SKIP += "already-stripped"
