HOMEPAGE = "https://www.sourceware.org/lvm2/"
SECTION = "utils"
DESCRIPTION = "LVM2 is a set of utilities to manage logical volumes in Linux."
LICENSE = "GPLv2 & LGPLv2.1 & BSD"

LIC_FILES_CHKSUM = "file://COPYING;md5=12713b4d9386533feeb07d6e4831765a \
                    file://COPYING.LIB;md5=fbc093901857fcd118f065f900982c24 \
                    file://COPYING.BSD;md5=d7e19e89ea9f54c1af1aa83c7b7122e7 \		    
"

SRC_URI = "file://lvm2/LVM2.${PV}.tgz \
           file://lvm2/0001-lvm2-set-default-preferred_names.patch \
           file://lvm2/0002-lvm2-default-allow-changes-with-duplicate-pvs.patch \
           file://lvm2/0003-devs-check-for-no-dev-when-dropping-aliases.patch \
           file://lvm2/0004-bugfix-lvm2-add-SSD.patch \
           file://lvm2/0005-bugfix-add-timeout-when-fail-to-wait-udev.patch \
           file://lvm2/0006-bugfix-fix-the-code-maybe-lead-to-buffer-over-bound-access.patch \
           file://lvm2/0007-enhancement-modify-default-log-level-to-error-level.patch \
           file://lvm2/0008-enhancement-add-dfx-log.patch \
           file://lvm2/0009-enhancement-syslog-more-when-use-libdevmapper-so.patch \
           file://lvm2/0010-enhancement-log-it-when-disk-slow.patch \
           file://lvm2/0011-bugfix-lvm2-fix-the-reuse-of-va_list.patch \
"

SRC_URI[sha256sum] = "4a63bc8a084a8ae3c7bc5e6530cac264139d218575c64416c8b99e3fe039a05c"
DEPENDS += "util-linux libaio"

S = "${WORKDIR}/LVM2.${PV}"

inherit autotools-brokensep pkgconfig systemd license

LVM2_PACKAGECONFIG = "dmeventd"
LVM2_PACKAGECONFIG_append_class-target = " \
    ${@bb.utils.filter('DISTRO_FEATURES', 'selinux', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'udev', '', d)} \
"

# odirect is always enabled because there currently is a bug in
# lib/device/dev-io.c which prevents compiling without it. It is
# better to stick to configurations that were actually tested by
# upstream...
PACKAGECONFIG ??= "odirect ${LVM2_PACKAGECONFIG}"

PACKAGECONFIG[dmeventd] = "--enable-dmeventd,--disable-dmeventd"
PACKAGECONFIG[odirect] = "--enable-o_direct,--disable-o_direct"
PACKAGECONFIG[readline] = "--enable-readline,--disable-readline,readline"
PACKAGECONFIG[selinux] = "--enable-selinux,--disable-selinux,libselinux"
PACKAGECONFIG[udev] = "--enable-udev_sync --enable-udev_rules --with-udevdir=${nonarch_base_libdir}/udev/rules.d,--disable-udev_sync --disable-udev_rules,udev"

# Unset user/group to unbreak install.
EXTRA_OECONF = "--with-user= \
                --with-group= \
                --enable-realtime \
                --enable-cmdlib \
                --enable-pkgconfig \
                --with-usrlibdir=${libdir} \
                --with-systemdsystemunitdir=${systemd_system_unitdir} \
                --disable-thin_check_needs_check \
                --with-thin-check=${sbindir}/thin_check \
                --with-thin-dump=${sbindir}/thin_dump \
                --with-thin-repair=${sbindir}/thin_repair \
                --with-thin-restore=${sbindir}/thin_restore \
"

