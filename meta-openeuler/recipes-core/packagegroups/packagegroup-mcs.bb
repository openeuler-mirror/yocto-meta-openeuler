SUMMARY = "packages for mcs feature of openEuler Embedded"
PACKAGE_ARCH = "${MACHINE_ARCH}"
inherit packagegroup

PR = "r1"

PACKAGES = "${PN}"

# MCS_FEATURES = "<openamp|jailhouse>  [client os]  [other properties] "
# no machine info in MCS_FEATURES
#
# According to MCS_FEATURES, select the implementation of bottom foundation and client os:
#  - screen is used to connect the tty device provided by client OS
#  - if openamp is used, mcs-km will be included
#  - if jailhouse is used, jailhouse will be included
RDEPENDS:${PN} = " \
screen \
mcs-linux \
${@bb.utils.contains('MCS_FEATURES', 'openamp', 'mcs-km', '', d)} \
${@bb.utils.contains('MCS_FEATURES', 'jailhouse', 'jailhouse', '', d)} \
${@bb.utils.contains('MCS_FEATURES', 'zephyr', 'zephyr-image', '', d)} \
${@bb.utils.contains('MCS_FEATURES', 'external-firmware', 'mcs-firmware', '', d)} \
${@bb.utils.contains('MCS_FEATURES', 'micrun', 'micrun', '', d)} \
${@bb.utils.contains('DISTRO_FEATURES', 'xen', 'mcs-km', '', d)} \
${@bb.utils.contains('DISTRO_FEATURES', 'xen', 'packagegroup-xen', '', d)} \
"

# mcs-firmware defaults to the zephyr.elf name, do not let it collide with
# the in-tree zephyr-image package.
python() {
    features = (d.getVar('MCS_FEATURES') or '').split()
    name = d.getVar('MCS_FIRMWARE_NAME') or 'zephyr'
    if 'zephyr' in features and 'external-firmware' in features and name == 'zephyr':
        bb.fatal("MCS_FEATURES enables both 'zephyr' and 'external-firmware' "
                 "while MCS_FIRMWARE_NAME is 'zephyr'; they would install the "
                 "same /lib/firmware/zephyr.elf. Set MCS_FIRMWARE_NAME to a "
                 "different name.")
}

### MCS DEPLOY TOOLS
RDEPENDS:${PN}:append:aarch64 = " mcsctl"
RDEPENDS:${PN}:append:x86-64 = " mcs-tools"
RDEPENDS:${PN}:append = " ${@bb.utils.contains('MCS_FEATURES', 'openamp', 'mcs-script', '', d)}"

# add openamp dev to sdk, debian.bbclass renames openamp-dev according to
# the libopen_amp.so.1 SONAME, so the sdk has to ask for the new name.
TOOLCHAIN_TARGET_TASK += " \
libopen-amp-dev \
libmetal-dev \
sysfsutils-dev \
"
# no support for riscv currently
TOOLCHAIN_TARGET_TASK:remove:riscv64 = " \
libopen-amp-dev \
libmetal-dev \
sysfsutils-dev \
"
