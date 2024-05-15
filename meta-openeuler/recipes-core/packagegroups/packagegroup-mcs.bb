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
"

### MCS DEPLOY TOOLS
RDEPENDS:${PN}:append:aarch64 = " mcsctl"
RDEPENDS:${PN}:append:x86-64 = " mcs-tools"

# add openamp dev to sdk
TOOLCHAIN_TARGET_TASK += " \
openamp-dev \
libmetal-dev \
sysfsutils-dev \
"
# no support for riscv currently
TOOLCHAIN_TARGET_TASK:remove:riscv64 = " \
openamp-dev \
libmetal-dev \
sysfsutils-dev \
"
