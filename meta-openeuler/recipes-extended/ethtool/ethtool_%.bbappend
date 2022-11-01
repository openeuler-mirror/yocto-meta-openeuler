PV = "5.15"

# ptest patch: avoid_parallel_tests.patch
SRC_URI = "file://${BP}.tar.xz \
        file://backport-ioctl-add-the-memory-free-operation-after-send_ioctl.patch \
        file://0001-rings-add-support-to-set-get-rx-buf-len.patch \
        file://0002-tunables-add-support-to-get-set-tx-copybreak-buf-siz.patch \
        file://0003-update-UAPI-header-copies.patch \
        file://0004-ethtool-add-support-to-get-set-tx-push-by-ethtool-G-.patch \
	  "

SRC_URI[sha256sum] = "686fd6110389d49c2a120f00c3cd5dfe43debada8e021e4270d74bbe452a116d"
