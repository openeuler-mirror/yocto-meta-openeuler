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
           file://rtos-defconfig \
"
FILESPATH:prepend += "${LOCAL_FILES}/${BPN}:"
S = "${WORKDIR}/${BPN}-${PV}"

#not split debug files with dwarfsrcfiles,no dwarfsrcfiles
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"

# Whether to split the suid apps into a seperate binary
BUSYBOX_SPLIT_SUID ?= "1"

export EXTRA_CFLAGS = "${CFLAGS}"
export EXTRA_LDFLAGS = "${LDFLAGS}"

EXTRA_OEMAKE = "CC='${CC}' LD='${CCLD}' V=1 ARCH=${TARGET_ARCH} CROSS_COMPILE=${TARGET_PREFIX} SKIP_STRIP=y HOSTCC='${BUILD_CC}' HOSTCPP='${BUILD_CPP}'"
EXTRA_OEMAKE = "CC='${CC}' V=1 ARCH=${ARCH} LD=${LD} CROSS_COMPILE=${TARGET_PREFIX}"
EXTRA_OEMAKE = "CC='${CC}' LD='${CCLD}' V=1 ARCH=${ARCH} CROSS_COMPILE=${TARGET_PREFIX} SKIP_STRIP=y HOSTCC='${BUILD_CC}' HOSTCPP='${BUILD_CPP}'"
#use host pkg-config add by openeuler
EXTRA_OECONF += "PKG_CONFIG=pkg-config"
EXTRA_OEMAKE += "PKG_CONFIG=pkg-config"

PACKAGES =+ "${PN}-httpd ${PN}-udhcpd ${PN}-udhcpc ${PN}-syslog ${PN}-mdev ${PN}-hwclock"

FILES:${PN}-httpd = "${sysconfdir}/init.d/busybox-httpd /srv/www"
FILES:${PN}-syslog = "${sysconfdir}/init.d/syslog* ${sysconfdir}/syslog-startup.conf* ${sysconfdir}/syslog.conf* ${systemd_unitdir}/system/syslog.service ${sysconfdir}/default/busybox-syslog"
FILES:${PN}-mdev = "${sysconfdir}/init.d/mdev ${sysconfdir}/mdev.conf ${sysconfdir}/mdev/*"
FILES:${PN}-udhcpd = "${sysconfdir}/init.d/busybox-udhcpd"
FILES:${PN}-udhcpc = "${sysconfdir}/udhcpc.d ${datadir}/udhcpc"
FILES:${PN}-hwclock = "${sysconfdir}/init.d/hwclock.sh"

INITSCRIPT_PACKAGES = "${PN}-httpd ${PN}-syslog ${PN}-udhcpd ${PN}-mdev ${PN}-hwclock"

INITSCRIPT_NAME:${PN}-httpd = "busybox-httpd"
INITSCRIPT_NAME:${PN}-hwclock = "hwclock.sh"
INITSCRIPT_NAME:${PN}-mdev = "mdev"
INITSCRIPT_PARAMS:${PN}-mdev = "start 04 S ."
INITSCRIPT_NAME:${PN}-syslog = "syslog"
INITSCRIPT_NAME:${PN}-udhcpd = "busybox-udhcpd"

SYSTEMD_PACKAGES = "${PN}-syslog"
SYSTEMD_SERVICE:${PN}-syslog = "${@bb.utils.contains('SRC_URI', 'file://syslog.cfg', 'busybox-syslog.service', '', d)}"

RDEPENDS:${PN}-syslog = "busybox"
CONFFILES:${PN}-syslog = "${sysconfdir}/syslog-startup.conf"
RCONFLICTS:${PN}-syslog = "rsyslog sysklogd syslog-ng"

CONFFILES:${PN}-mdev = "${sysconfdir}/mdev.conf"

RRECOMMENDS:${PN} = "${PN}-udhcpc"

RDEPENDS:${PN} = "${@["", "busybox-inittab"][(d.getVar('VIRTUAL-RUNTIME_init_manager') == 'busybox')]}"

do_configure() {
        cp ../rtos-defconfig .config
        set -e
        unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS
        yes '' | oe_runmake oldconfig
}

do_compile () {
        unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS
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
        sed -i "s:^/bin/:BASE_BINDIR/:" busybox.links*
        sed -i "s:^/sbin/:BASE_SBINDIR/:" busybox.links*
        sed -i "s:^/usr/bin/:BINDIR/:" busybox.links*
        sed -i "s:^/usr/sbin/:SBINDIR/:" busybox.links*

        # Move arch/link to BINDIR to match coreutils
        sed -i "s:^BASE_BINDIR/arch:BINDIR/arch:" busybox.links*
        sed -i "s:^BASE_BINDIR/link:BINDIR/link:" busybox.links*

        sed -i "s:^BASE_BINDIR/:${base_bindir}/:" busybox.links*
        sed -i "s:^BASE_SBINDIR/:${base_sbindir}/:" busybox.links*
        sed -i "s:^BINDIR/:${bindir}/:" busybox.links*
        sed -i "s:^SBINDIR/:${sbindir}/:" busybox.links*

        install -d ${D}${sysconfdir}/init.d

        if ! grep -q "CONFIG_FEATURE_INDIVIDUAL=y" ${B}/.config; then
                # Install ${base_bindir}/busybox, and the ${base_bindir}/sh link so the postinst script
                # can run. Let update-alternatives handle the rest.
                install -d ${D}${base_bindir}
                if [ "${BUSYBOX_SPLIT_SUID}" = "1" ]; then
                        install -m 4755 ${B}/busybox.suid ${D}${base_bindir}
                        install -m 0755 ${B}/busybox.nosuid ${D}${base_bindir}
                        install -m 0644 ${S}/busybox.links.suid ${D}${sysconfdir}
                        install -m 0644 ${S}/busybox.links.nosuid ${D}${sysconfdir}
                        if grep -q "CONFIG_SH_IS_ASH=y" ${B}/.config; then
                                ln -sf busybox.nosuid ${D}${base_bindir}/sh
                        fi
                        # Keep a default busybox for people who want to invoke busybox directly.
                        # This is also useful for the on device upgrade. Because we want
                        # to use the busybox command in postinst.
                        ln -sf busybox.nosuid ${D}${base_bindir}/busybox
                else
                        if grep -q "CONFIG_FEATURE_SUID=y" ${B}/.config; then
                                install -m 4755 ${B}/busybox ${D}${base_bindir}
                        else
                                install -m 0755 ${B}/busybox ${D}${base_bindir}
                        fi
                        install -m 0644 ${S}/busybox.links ${D}${sysconfdir}
                        if grep -q "CONFIG_SH_IS_ASH=y" ${B}/.config; then
                                ln -sf busybox ${D}${base_bindir}/sh
                        fi
                        # We make this symlink here to eliminate the error when upgrading together
                        # with busybox-syslog. Without this symlink, the opkg may think of the
                        # busybox.nosuid as obsolete and remove it, resulting in dead links like
                        # ${base_bindir}/sed -> ${base_bindir}/busybox.nosuid. This will make upgrading busybox-syslog fail.
                        # This symlink will be safely deleted in postinst, thus no negative effect.
                        ln -sf busybox ${D}${base_bindir}/busybox.nosuid
                fi
        else
                install -d ${D}${base_bindir} ${D}${bindir} ${D}${libdir}
                cat busybox.links | while read FILE; do
                        NAME=`basename "$FILE"`
                        install -m 0755 "0_lib/$NAME" "${D}$FILE.${BPN}"
                done
                # add suid bit where needed
                for i in `grep -E "APPLET.*BB_SUID_((MAYBE|REQUIRE))" include/applets.h | grep -v _BB_SUID_DROP | cut -f 3 -d '(' | cut -f 1 -d ','`; do
                        find ${D} -name $i.${BPN} -exec chmod a+s {} \;
                done
                install -m 0755 0_lib/libbusybox.so.${PV} ${D}${libdir}/libbusybox.so.${PV}
                ln -sf sh.${BPN} ${D}${base_bindir}/sh
                ln -sf ln.${BPN} ${D}${base_bindir}/ln
                ln -sf test.${BPN} ${D}${bindir}/test
                if [ -f ${D}/linuxrc.${BPN} ]; then
                        mv ${D}/linuxrc.${BPN} ${D}/linuxrc
                fi
                install -m 0644 ${S}/busybox.links ${D}${sysconfdir}
        fi

        # Remove the sysvinit specific configuration file for systemd systems to avoid confusion
        if ${@bb.utils.contains('DISTRO_FEATURES', 'sysvinit', 'false', 'true', d)}; then
                rm -f ${D}${sysconfdir}/syslog-startup.conf
        fi
}
