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
"

SRC_URI[sha256sum] = "3b752a3329827907ac3812f2831dfecf51c8c41c55d2d69cfb9c53ca06449fc6"
