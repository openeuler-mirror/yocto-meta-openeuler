# version in openEuler

OPENEULER_SRC_URI_REMOVE = "https"

PV = "1.14.8"

LIC_FILES_CHKSUM = "file://COPYING;md5=6423dcd74d7be9715b0db247fd889da3 \
                    file://dbus/dbus.h;beginline=6;endline=20;md5=866739837ccd835350af94dccd6457d8"


# apply openEuler source package
SRC_URI:remove = " \
           file://clear-guid_from_server-if-send_negotiate_unix_f.patch \
"

# apply src and patches from openEuler
SRC_URI:prepend = "file://dbus-${PV}.tar.xz \
           file://bugfix-let-systemd-restart-dbus-when-the-it-enters-failed.patch \
           file://print-load-average-when-activate-service-timeout.patch \
           file://backport-tools-Use-Python3-for-GetAllMatchRules.patch \
"

# checksum changed
SRC_URI[md5sum] = "da42f55aeec51b355587bc3062fc2d41"
SRC_URI[sha256sum] = "a6bd5bac5cf19f0c3c594bdae2565a095696980a683a0ef37cb6212e093bde35"
