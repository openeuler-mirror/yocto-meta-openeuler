# apply openeuler source package
OPENEULER_REPO_NAME = "bluez"

PV = "5.71"

LIC_FILES_CHKSUM = "file://COPYING;md5=12f884d2ae1ff87c09e5b7ccc2c4ca7e \
                    file://COPYING.LIB;md5=fb504b67c50331fc78734fed90fb0e09 \
                    file://src/main.c;beginline=1;endline=24;md5=0ad83ca0dc37ab08af448777c581e7ac"

# these two patches fix CVE-2021-0129 and CVE-2021-3658, which isn't suitable version 5.54
# openeuler package has another patches to fix these cves.
SRC_URI:remove = "\
    file://0001-adapter-Fix-storing-discoverable-setting.patch \
    file://0001-shared-gatt-server-Fix-not-properly-checking-for-sec.patch \
"

SRC_URI:prepend = "\
    file://bluez-${PV}.tar.xz \
    file://backport-bluez-disable-test-mesh-crypto.patch \
"
# From bluez5_5.72
EXTRA_OECONF += "--enable-pie"
do_install:append() {
	install -d ${D}${INIT_D_DIR}
	install -m 0755 ${WORKDIR}/init ${D}${INIT_D_DIR}/bluetooth

	install -d ${D}${sysconfdir}/bluetooth/
	if [ -f ${S}/profiles/network/network.conf ]; then
		install -m 0644 ${S}/profiles/network/network.conf ${D}/${sysconfdir}/bluetooth/
	fi
	if [ -f ${S}/profiles/input/input.conf ]; then
		install -m 0644 ${S}/profiles/input/input.conf ${D}/${sysconfdir}/bluetooth/
	fi
}

# openeuler do not has udev package, which is not necessary for bluez
# so remove it.
PACKAGECONFIG:remove = "udev"

# testtools depends python3-core python3-dbus python3-pygobject, we do not need these
RDEPENDS:${PN}-testtools:openeuler-prebuilt = ""

# adapte md5 checksum
LIC_FILES_CHKSUM = "file://COPYING;md5=12f884d2ae1ff87c09e5b7ccc2c4ca7e \
                    file://COPYING.LIB;md5=fb504b67c50331fc78734fed90fb0e09 \
                    file://src/main.c;beginline=1;endline=24;md5=0ad83ca0dc37ab08af448777c581e7ac"
