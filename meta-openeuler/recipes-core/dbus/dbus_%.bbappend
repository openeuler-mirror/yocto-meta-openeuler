# version in openEuler
PV = "1.14.0"

# apply openEuler source package
SRC_URI_remove = "https://dbus.freedesktop.org/releases/dbus/dbus-${PV}.tar.gz \
file://clear-guid_from_server-if-send_negotiate_unix_f.patch \
"

SRC_URI_prepend = "file://dbus/dbus-${PV}.tar.xz "

# apply patches from openEuler
SRC_URI += "\
file://bugfix-let-systemd-restart-dbus-when-the-it-enters-failed.patch \
file://backport-tools-Use-Python3-for-GetAllMatchRules.patch \
file://print-load-average-when-activate-service-timeout.patch \
"

# checksum changed
SRC_URI[md5sum] = "ddd5570aff05191dbee8e42d751f1b7d"
SRC_URI[sha256sum] = "ccd7cce37596e0a19558fd6648d1272ab43f011d80c8635aea8fd0bad58aebd4"
LIC_FILES_CHKSUM = "file://COPYING;md5=10dded3b58148f3f1fd804b26354af3e \
                    file://dbus/dbus.h;beginline=6;endline=20;md5=866739837ccd835350af94dccd6457d8"

# remove package config which not support now in openEuler.
PACKAGECONFIG_remove = "x11 systemd"
