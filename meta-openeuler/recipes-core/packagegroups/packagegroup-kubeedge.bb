SUMMARY = "packages for kubeedge"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PR = "r1"

PACKAGES = "${PN}"

RDEPENDS:${PN} = " \
packagegroup-isulad \
edgecore \
keadm \
ntpdate \
cri-tools \
cni \
"

