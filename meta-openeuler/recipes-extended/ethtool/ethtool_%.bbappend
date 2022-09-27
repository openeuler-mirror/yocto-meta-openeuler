PV = "5.15"

# ptest patch: avoid_parallel_tests.patch
SRC_URI = "file://${BP}.tar.xz \
	   file://backport-ioctl-add-the-memory-free-operation-after-send_ioctl.patch \
	  "

SRC_URI[sha256sum] = "686fd6110389d49c2a120f00c3cd5dfe43debada8e021e4270d74bbe452a116d"
