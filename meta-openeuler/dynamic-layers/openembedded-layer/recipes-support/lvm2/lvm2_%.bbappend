# main bbfile: meta-oe/recipes-support/lvm2/lvm2_2.03.11.bb?h=hardknott

require lvm2-src.inc

# remove strong dependence on udev, use condition statements to decide whether to depend udev
# keep the same as before
# use PACKAGECONFIG instead of LVM2_PACKAGECONFIG
LVM2_PACKAGECONFIG:remove:class-target = " \
    udev \
"
PACKAGECONFIG:append:class-target = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'udev', '', d)} \
"


# from poky lvm2_2.03.22.bb

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI += " \
        file://tweak-for-lvmdbusd.patch \
        file://0001-lvmdbusd-create-dirs-for-lock-file.patch \
"

inherit python3native

do_install:append() {

    # following files only exist when package config `dbus` enabled
    sed -i -e '1s,#!.*python.*,#!${USRBINPATH}/env python3,' \
        ${D}${sbindir}/lvmdbusd \
        ${D}${PYTHON_SITEPACKAGES_DIR}/lvmdbusd/lvmdb.py \
        ${D}${PYTHON_SITEPACKAGES_DIR}/lvmdbusd/lvm_shell_proxy.py \
    || true
}

SYSTEMD_SERVICE:${PN} += "${@bb.utils.contains('PACKAGECONFIG', 'dbus', 'lvm2-lvmdbusd.service', '', d)} \
"

PACKAGECONFIG[dbus] = "--enable-dbus-service,--disable-dbus-service,,python3-dbus python3-pyudev"

FILES:${PN} += " \
    ${PYTHON_SITEPACKAGES_DIR}/lvmdbusd \
    ${datadir}/dbus-1/system-services/com.redhat.lvmdbus1.service \
"

RDEPENDS:${PN} = "bash"
