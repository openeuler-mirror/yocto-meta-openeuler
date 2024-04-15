# version in openEuler

PV = "1.14.8"

LIC_FILES_CHKSUM = "file://COPYING;md5=6423dcd74d7be9715b0db247fd889da3 \
                    file://dbus/dbus.h;beginline=6;endline=20;md5=866739837ccd835350af94dccd6457d8"


# apply openEuler source package
SRC_URI:remove = " \
           file://clear-guid_from_server-if-send_negotiate_unix_f.patch \
"

# apply src and patches from openEuler
SRC_URI:prepend = "file://${BP}.tar.xz \
            file://bugfix-let-systemd-restart-dbus-when-the-it-enters-failed.patch \
            file://print-load-average-when-activate-service-timeout.patch \
            file://backport-tools-Use-Python3-for-GetAllMatchRules.patch \
            file://backport-Do-not-crash-when-reloading-configuration.patch \
"

# checksum changed
SRC_URI[sha256sum] = "a6bd5bac5cf19f0c3c594bdae2565a095696980a683a0ef37cb6212e093bde35"

EXTRA_OECONF += "--runstatedir=/run"
DEPENDS = "expat virtual/libintl autoconf-archive-native glib-2.0 libbsd-native"

do_install() {
	autotools_do_install

	if ${@bb.utils.contains('DISTRO_FEATURES', 'sysvinit', 'true', 'false', d)}; then
		install -d ${D}${sysconfdir}/init.d
		sed 's:@bindir@:${bindir}:' < ${WORKDIR}/dbus-1.init >${WORKDIR}/dbus-1.init.sh
		install -m 0755 ${WORKDIR}/dbus-1.init.sh ${D}${sysconfdir}/init.d/dbus-1
		install -d ${D}${sysconfdir}/default/volatiles
		echo "d messagebus messagebus 0755 /run/dbus none" \
		     > ${D}${sysconfdir}/default/volatiles/99_dbus
	fi

	if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
		for i in dbus.target.wants sockets.target.wants multi-user.target.wants; do \
			install -d ${D}${systemd_system_unitdir}/$i; done
		install -m 0644 ${B}/bus/dbus.service ${B}/bus/dbus.socket ${D}${systemd_system_unitdir}/
		ln -fs ../dbus.socket ${D}${systemd_system_unitdir}/dbus.target.wants/dbus.socket
		ln -fs ../dbus.socket ${D}${systemd_system_unitdir}/sockets.target.wants/dbus.socket
		ln -fs ../dbus.service ${D}${systemd_system_unitdir}/multi-user.target.wants/dbus.service
	fi


	mkdir -p ${D}${localstatedir}/lib/dbus

	chown messagebus:messagebus ${D}${localstatedir}/lib/dbus

	chown root:messagebus ${D}${libexecdir}/dbus-daemon-launch-helper
	chmod 4755 ${D}${libexecdir}/dbus-daemon-launch-helper

	# Remove Red Hat initscript
	rm -rf ${D}${sysconfdir}/rc.d

	# Remove empty testexec directory as we don't build tests
	rm -rf ${D}${libdir}/dbus-1.0/test

	# Remove /var/run as it is created on startup
	rm -rf ${D}${localstatedir}/run
}
