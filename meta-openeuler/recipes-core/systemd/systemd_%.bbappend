# main bbfile: openembedded-core/meta/recipes-core/systemd/systemd_253.7.bb

#version in openEuler
PV = "255"
S = "${WORKDIR}/${BP}"

require systemd-openeuler.inc

# depmodwrapper is not valid to do depmod in buildtime, add a service to do it in runtime as a workaround.
# as modutils.sh is not run under systemd
PACKAGE_BEFORE_PN:append = " ${PN}-depmod "
SRC_URI:append = " file://systemd-depmod.service"
# 0026 patch was for systemd v253 era and does not apply to v255 source
SRC_URI:remove = "file://0026-src-boot-efi-efi-string.c-define-wchar_t-from-__WCHA.patch"
# 0002-binfmt patch from poky v255.21.bb fails on openeuler v255 source (hunk mismatch)
SRC_URI:remove = "file://0002-binfmt-Don-t-install-dependency-links-at-install-tim.patch"
# 0004 patch moves sysusers.d etc from /lib to /usr/lib; openeuler v255 already uses ${prefix}/lib so patch does not apply
SRC_URI:remove = "file://0004-Move-sysusers.d-sysctl.d-binfmt.d-modules-load.d-to-.patch"
# 27254 and 27253 are oe-core backport patches; openeuler v255 already includes these changes
SRC_URI:remove = "file://27254.patch file://27253.patch"
# openeuler patches apply with fuzz; INSANE_SKIP does not suppress do_qa_patch errors
# systemd v255 removed the -Dgnu-efi meson option; clear this PACKAGECONFIG entry
# so neither the enabled nor disabled flag (-Dgnu-efi=false) is passed to meson
PACKAGECONFIG[gnu-efi] = ""
FILES:${PN}-depmod = "${systemd_unitdir}/system/systemd-depmod.service"
SYSTEMD_SERVICE:${PN}-depmod = "systemd-depmod.service"
do_install:append () {
    install -m 0644 ${WORKDIR}/systemd-depmod.service ${D}${systemd_unitdir}/system/systemd-depmod.service
    ln -sf ../systemd-depmod.service ${D}${systemd_unitdir}/system/sysinit.target.wants/systemd-depmod.service
    # the default DNS servers systemd resolved use cannot be accessed in China
    # so we need to change the default DNS servers to the ones that can be accessed in China
    # for example, we can use AliDNS servers
    sed -i 's/#DNS=/DNS=223.5.5.5/' ${D}${sysconfdir}/systemd/resolved.conf
}

# glib needs meson, meson needs python3-native
# here use nativesdk's meson-native and python3-native
DEPENDS:remove = "python3-native"

FILES:udev += " \
               ${rootlibexecdir}/udev/rules.d/40-elevator.rules \
               ${rootlibexecdir}/udev/rules.d/73-idrac.rules \
               ${rootlibexecdir}/udev/iocost \
               ${rootlibexecdir}/udev/rules.d/60-dmi-id.rules \
               ${rootlibexecdir}/udev/rules.d/60-persistent-storage-mtd.rules \
               ${rootlibexecdir}/udev/rules.d/90-iocost.rules \
"

# v255 new files not assigned in systemd_253.7.bb base recipe
FILES:${PN} += " \
               ${base_sbindir}/mount.ddi \
               ${sysconfdir}/credstore/ \
               ${sysconfdir}/credstore.encrypted/ \
               ${exec_prefix}/lib/credstore \
"
