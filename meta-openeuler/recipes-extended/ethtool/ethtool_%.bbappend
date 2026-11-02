# the main bb file: yocto-poky/meta/recipes-extended/ethtool/ethtool_5.16.bb

PV = "6.6"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# ptest patch: avoid_parallel_tests.patch
SRC_URI:prepend = "file://${BP}.tar.xz \
            file://netlink-fix-typo.patch \
            file://ethtool-add-suppport-specifications-for-vxlan-by-eth.patch \
            file://backport-ethtool-add-support-dump-registers-for-hibmcge-drive.patch \
            file://backport-ethtool-hibmcge-fix-wrong-register-address-in-pretty-print-of-ethtool-d-command.patch \
            file://backport-ethtool-Fix-SFF-8472-transceiver-module-identificati.patch \
            file://backport-net-ethtool-Add-default-branch-to-sff8636_show_all_i.patch \
            file://backport-qsfp-Better-handling-of-Page-03h-netlink-read-failur.patch \
            file://backport-module-eeprom-treat-zero-arguments-like-any-other-ar.patch \
            file://backport-qsf-Better-handling-of-Page-A2h-netlink-read-failure.patch \
            file://ethtool-add-support-dump-registers-for-unic-driver.patch \
            file://backport-add-NULL-check-before-jsonw_string_field.patch \
            file://backport-add-NULL-check-for-get_string-in-features.c.patch \
            file://netlink-fix-missing-headers-in-text-output.patch \
            file://netlink-fix-print_string-when-the-value-is-NULL.patch \
           "

SRC_URI[sha256sum] = "833a8493cb9cd5809ab59743092d9a38742c282290800e9626407511bbcebf9e"

RDEPENDS:${PN}-ptest += "bash"
