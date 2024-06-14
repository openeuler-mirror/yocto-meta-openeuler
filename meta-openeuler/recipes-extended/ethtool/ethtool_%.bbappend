PV = "5.15"

# ptest patch: avoid_parallel_tests.patch
SRC_URI = "file://${BP}.tar.xz \
    file://backport-ioctl-add-the-memory-free-operation-after-send_ioctl.patch \
    file://0001-rings-add-support-to-set-get-rx-buf-len.patch \
    file://0002-tunables-add-support-to-get-set-tx-copybreak-buf-siz.patch \
    file://0003-update-UAPI-header-copies.patch \
    file://0004-ethtool-add-support-to-get-set-tx-push-by-ethtool-G-.patch \
    file://0005-ethtool-add-suppport-specifications-for-vxlan-by-eth.patch \
    file://0006-hns3-add-support-dump-registers-for-hns3-driver.patch \
    file://backport-cmis-Rename-CMIS-parsing-functions.patch \
    file://backport-cmis-Initialize-CMIS-memory-map.patch \
    file://backport-cmis-Use-memory-map-during-parsing.patch \
    file://backport-cmis-Consolidate-code-between-IOCTL-and-netlink-path.patch \
    file://backport-sff-8636-Rename-SFF-8636-parsing-functions.patch \
    file://backport-sff-8636-Initialize-SFF-8636-memory-map.patch \
    file://backport-sff-8636-Use-memory-map-during-parsing.patch \
    file://backport-sff-8636-Consolidate-code-between-IOCTL-and-netlink-.patch \
    file://backport-sff-8079-Split-SFF-8079-parsing-function.patch \
    file://backport-netlink-eeprom-Export-a-function-to-request-an-EEPRO.patch \
    file://backport-cmis-Request-specific-pages-for-parsing-in-netlink-p.patch \
    file://backport-sff-8636-Request-specific-pages-for-parsing-in-netli.patch \
    file://backport-sff-8079-Request-specific-pages-for-parsing-in-netli.patch \
    file://backport-netlink-eeprom-Defer-page-requests-to-individual-par.patch \
    file://backport-sff-8636-Use-an-SFF-8636-specific-define-for-maximum.patch \
    file://backport-sff-common-Move-OFFSET_TO_U16_PTR-to-common-header-f.patch \
    file://backport-sff-8636-Print-Power-set-and-Power-override-bits.patch \
    file://backport-ethtool-Add-ability-to-control-transceiver-modules-p.patch \
    file://backport-ethtool-Add-support-for-OSFP-transceiver-modules.patch \
    file://backport-ethtool-Add-support-for-more-CMIS-transceiver-module.patch \
"

SRC_URI[sha256sum] = "3b752a3329827907ac3812f2831dfecf51c8c41c55d2d69cfb9c53ca06449fc6"
