# apply openeuler source package
OPENEULER_LOCAL_NAME = "bluez"

PV = "5.71"

SRC_URI:prepend = "\
    file://bluez-${PV}.tar.xz \
    file://backport-bluez-disable-test-mesh-crypto.patch \
    file://add-sw_64-support.patch \
    file://0001-Fix-crash-after-pair-command.patch \
    file://Fix-memory-leak.patch \
    file://bluez-CVE-2026-75032.patch \
    file://backport-0001-CVE-2026-19774.patch \
    file://backport-0002-CVE-2026-19774.patch \
    file://backport-CVE-2026-80185.patch \
    file://backport-CVE-2026-80186.patch \
"

# removed by rpi in 5.66 version
SRC_URI:remove = "file://0004-Move-the-43xx-firmware-into-lib-firmware.patch \
                file://0001-Allow-using-obexd-without-systemd-in-the-user-sessio.patch \
                "

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"
SRC_URI:append:rpi = " \
	file://0004-Move-the-hciattach-firmware-into-lib-firmware.patch \
"

# remove udev if not enable systemd
PACKAGECONFIG:remove = "${@bb.utils.contains('DISTRO_FEATURES', 'systemd', '', 'udev', d)}"

# testtools depends python3-core python3-dbus python3-pygobject, we do not need these
RDEPENDS:${PN}-testtools:openeuler-prebuilt = ""

INSANE_SKIP:${PN}-testtools += "file-rdeps"

# From oe-core bluez5_5.71.bb
EXTRA_OECONF += "--enable-pie"

FILES:${PN} += "${@bb.utils.contains('DISTRO_FEATURES', 'systemd', "/usr/lib/systemd/user/dbus-org.bluez.obex.service", '', d)}"
