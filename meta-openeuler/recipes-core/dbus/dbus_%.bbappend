# version in openEuler
PV = "1.12.20"

# apply openEuler source package
SRC_URI_remove = "https://dbus.freedesktop.org/releases/dbus/dbus-${PV}.tar.gz \
"

SRC_URI_prepend = "file://dbus-${PV}.tar.gz "

# apply patches from openEuler
SRC_URI += "\
	file://bugfix-let-systemd-restart-dbus-when-the-it-enters-failed.patch \
	file://print-load-average-when-activate-service-timeout.patch \
	file://backport-CVE-2022-42010.patch \
	file://backport-CVE-2022-42011.patch \
	file://backport-CVE-2022-42012.patch \
	file://backport-bus-dir-watch-Do-not-crash-with-128-dirs.patch	\
	file://backport-Do-not-crash-when-reloading-configuration.patch \
	file://backport-Stop-using-selinux_set_mapping-function.patch \
	file://backport-bus-Don-t-pass-systemd-environment-variables-to-acti.patch \
	file://backport-bus-Notify-systemd-when-we-are-ready.patch \
"

