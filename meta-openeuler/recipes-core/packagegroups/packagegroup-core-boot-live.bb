SUMMARY = "live boot requirements"
DESCRIPTION = "The live set of packages required to boot the system"
PR = "r1"
PACKAGE_ARCH = "${MACHINE_ARCH}"
inherit packagegroup

# live should use this VIRTUAL-RUNTIME as we don't want systemd:
# Notice: we need busybox-inittab to setup in RDEPENDS
DISTRO_FEATURES_BACKFILL_CONSIDERED:append := " systemd"
VIRTUAL-RUNTIME_dev_manager := "busybox-mdev"
VIRTUAL-RUNTIME_init_manager := "busybox"
VIRTUAL-RUNTIME_initscripts := "initscripts"
VIRTUAL-RUNTIME_keymaps := "keymaps"
VIRTUAL-RUNTIME_login_manager := "busybox"

EFI_PROVIDER ??= "grub-efi"

SYSVINIT_SCRIPTS = "${@bb.utils.contains('MACHINE_FEATURES', 'rtc', '${VIRTUAL-RUNTIME_base-utils-hwclock}', '', d)} \
                    modutils-initscripts \
                    init-ifupdown \ 
                    ${VIRTUAL-RUNTIME_initscripts} \
                   "

RDEPENDS:${PN} = "\
    base-files \
    base-passwd \
    ${VIRTUAL-RUNTIME_base-utils} \
    ${@bb.utils.contains("DISTRO_FEATURES", "sysvinit", "${SYSVINIT_SCRIPTS}", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "keyboard", "${VIRTUAL-RUNTIME_keymaps}", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "efi", "${EFI_PROVIDER} kernel", "", d)} \
    ${VIRTUAL-RUNTIME_login_manager} \
    ${VIRTUAL-RUNTIME_init_manager} \
    ${VIRTUAL-RUNTIME_dev_manager} \
    ${VIRTUAL-RUNTIME_update-alternatives} \
    ${MACHINE_ESSENTIAL_EXTRA_RDEPENDS} \
    os-base \
    busybox-inittab \
    "
#    kernel 
#    kernel-img 
#    kernel-image 
#    kernel-vmlinux 

# No rule to make target "Image" for x86-64, remove it
RDEPENDS:${PN}:remove:x86-64 = "kernel-img"

RRECOMMENDS:${PN} = "\
    ${VIRTUAL-RUNTIME_base-utils-syslog} \
    ${MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS}"
