# mcs patch for ok3568 devicetree
SRC_URI:append:ok3568 = " \
    ${@bb.utils.contains('MCS_FEATURES', 'openamp', 'file://patches/0003-ok3568-support-mcs.patch', '', d)} \
"
