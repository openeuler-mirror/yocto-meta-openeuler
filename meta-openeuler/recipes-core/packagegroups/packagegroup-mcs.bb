SUMMARY = "packages for mcs"
inherit packagegroup

PR = "r1"

PACKAGES = "${PN}"

# MCS_FEATURES = "<openamp|jailhouse>  [client os]  [other properties] "
# no machine info in MCS_FEATURES
#
# According to MCS_FEATURES, select the implementation of bottom foundation and client os:
#  - if openamp is used, mcs-linux and mcs-km will be included
#  - if jailhouse is used, jailhouse will be included
RDEPENDS:${PN} = " \
screen \
mcs-km \
mcs-tools \
${@bb.utils.contains('MCS_FEATURES', 'openamp', 'mcs-linux', '', d)} \
${@bb.utils.contains('MCS_FEATURES', 'jailhouse', 'jailhouse', '', d)} \
${@bb.utils.contains('MCS_FEATURES', 'zephyr', 'zephyr-image', '', d)} \
"
