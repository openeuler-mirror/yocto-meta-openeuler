# version in openEuler
PV = "1.14.0"

LIC_FILES_CHKSUM = "file://COPYING;md5=10dded3b58148f3f1fd804b26354af3e \
                    file://dbus/dbus.h;beginline=6;endline=20;md5=866739837ccd835350af94dccd6457d8"


# apply openEuler source package
SRC_URI:remove = "https://dbus.freedesktop.org/releases/dbus/dbus-${PV}.tar.gz \
           file://clear-guid_from_server-if-send_negotiate_unix_f.patch \
"

# apply src and patches from openEuler
SRC_URI:prepend = "file://dbus-${PV}.tar.xz \
           file://bugfix-let-systemd-restart-dbus-when-the-it-enters-failed.patch \
           file://print-load-average-when-activate-service-timeout.patch \
           file://backport-tools-Use-Python3-for-GetAllMatchRules.patch \
           file://backport-CVE-2022-42012.patch \
           file://backport-CVE-2022-42011.patch \
           file://backport-CVE-2022-42010.patch \
"

# checksum changed
SRC_URI[md5sum] = "ddd5570aff05191dbee8e42d751f1b7d"
SRC_URI[sha256sum] = "ccd7cce37596e0a19558fd6648d1272ab43f011d80c8635aea8fd0bad58aebd4"
