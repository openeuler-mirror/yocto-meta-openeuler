# bbfile: yoct--poky/recipes-connectivity/bluez5/bluez5_5.56.bb

OPENEULER_SRC_URI_REMOVE = "https"
# apply openeuler source package
OPENEULER_REPO_NAME = "bluez"

PV = "5.54"

# these two patches fix CVE-2021-0129 and CVE-2021-3658, which isn't suitable version 5.54
# openeuler package has another patches to fix these cves.
SRC_URI_remove = "\
    ${KERNELORG_MIRROR}/linux/bluetooth/bluez-${PV}.tar.xz \
    file://0001-adapter-Fix-storing-discoverable-setting.patch \
    file://0001-shared-gatt-server-Fix-not-properly-checking-for-sec.patch \
"

SRC_URI_prepend = "file://bluez-${PV}.tar.xz \
    file://0001-obex-Use-GLib-helper-function-to-manipulate-paths.patch \
    file://0001-build-Always-define-confdir-and-statedir.patch \
    file://0002-systemd-Add-PrivateTmp-and-NoNewPrivileges-options.patch \
    file://0003-systemd-Add-more-filesystem-lockdown.patch \
    file://0004-systemd-More-lockdown.patch \
    file://backport-CVE-2021-3588.patch \
    file://backport-bluez-disable-test-mesh-crypto.patch \
    file://backport-media-rename-local-function-conflicting-with-pause-2.patch \
    file://backport-CVE-2020-27153.patch \
    file://backport-0001-CVE-2021-3658.patch \
    file://backport-0002-CVE-2021-3658.patch \
    file://backport-CVE-2021-43400.patch \
    file://backport-0001-CVE-2021-0129.patch \
    file://backport-0002-CVE-2021-0129.patch \
    file://backport-0003-CVE-2021-0129.patch \
    file://backport-0004-CVE-2021-0129.patch \
    file://backport-CVE-2022-0204.patch \
    file://backport-CVE-2021-41229.patch \
    file://backport-CVE-2022-39176.patch \
    file://backport-0001-CVE-2022-39177.patch \
    file://backport-0002-CVE-2022-39177.patch \
    file://backport-CVE-2023-27349.patch \
"

# openeuler do not has udev package, which is not necessary for bluez
# so remove it.
PACKAGECONFIG_remove = "udev"

# testtools depends python3-core python3-dbus python3-pygobject, we do not need these
RDEPENDS_${PN}-testtools = ""

# adapte md5 checksum
LIC_FILES_CHKSUM = "file://COPYING;md5=12f884d2ae1ff87c09e5b7ccc2c4ca7e \
                    file://COPYING.LIB;md5=fb504b67c50331fc78734fed90fb0e09 \
                    file://src/main.c;beginline=1;endline=24;md5=9bc54b93cd7e17bf03f52513f39f926e"