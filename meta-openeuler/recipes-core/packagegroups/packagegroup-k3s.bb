SUMMARY = "packages for k3s"

PACKAGE_ARCH = "${MACHINE_ARCH}"

PR = "r1"

inherit packagegroup

REQUIRED_DISTRO_FEATURES ?= "seccomp"

PACKAGES = " \ 
  ${PN} \
"

RDEPENDS:${PN} = " \
packagegroup-isulad \ 
cni \
cri-tools \
"

