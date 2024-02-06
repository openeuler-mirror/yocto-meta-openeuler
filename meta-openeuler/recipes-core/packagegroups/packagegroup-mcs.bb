SUMMARY = "packages for mcs feature of openEuler Embedded"
inherit packagegroup

PR = "r1"

PACKAGES = "${PN}"

# MCS_FEATURES = "<openamp|jailhouse>  [client os]  [other properties] "
# no machine info in MCS_FEATURES
#
# According to MCS_FEATURES, select the implementation of bottom foundation and client os:
#  - screen is used to connect the tty device provided by client OS
#  - if openamp is used, mcs-linux and mcs-km will be included
#  - if jailhouse is used, jailhouse will be included
RDEPENDS:${PN} = " \
screen \
mcs-tools \
${@bb.utils.contains('MCS_FEATURES', 'openamp', 'mcs-linux kernel-module-mcs-km', '', d)} \
${@bb.utils.contains('MCS_FEATURES', 'jailhouse', 'jailhouse kernel-module-mcs-ivshmem', '', d)} \
${@bb.utils.contains('MCS_FEATURES', 'zephyr', 'zephyr-image', '', d)} \
"

RDEPENDS:${PN}:append:aarch64 = "\
mcsctl \
"
