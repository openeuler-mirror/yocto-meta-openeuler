# version in openEuler

PV = "1.14.8"

# apply src and patches from openEuler 1.16.2
SRC_URI:prepend = "file://${BP}.tar.xz \
            file://bugfix-let-systemd-restart-dbus-when-the-it-enters-failed.patch \
            file://print-load-average-when-activate-service-timeout.patch \
            file://backport-tools-Use-Python3-for-GetAllMatchRules.patch \
            "

# remove scarthgap patches that conflict
SRC_URI:remove = " \
           file://clear-guid_from_server-if-send_negotiate_unix_f.patch \
"

EXTRA_OECONF += "--runstatedir=/run"
DEPENDS = "expat virtual/libintl autoconf-archive-native glib-2.0 libbsd-native"

do_install:append() {
        # /run is a runtime directory; remove from ${D} to avoid installed-vs-shipped QA error
        # (--runstatedir=/run causes make install to create ${D}/run/dbus at build time)
        rm -rf ${D}/run
}
