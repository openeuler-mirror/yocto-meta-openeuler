SUMMARY = "packages for k3s"

PACKAGE_ARCH = "${MACHINE_ARCH}"

PR = "r1"

inherit packagegroup features_check
inherit cni_networking

REQUIRED_DISTRO_FEATURES ?= "seccomp"


PACKAGES = "\
  ${PN} \
  ${PN}-server \
  ${PN}-agent \
  "

RPROVIDES:${PN} = " \
    ${PN}-server \
    ${PN}-agent \
"

RDEPENDS:${PN}-server = " \
    packagegroup-oci \
    k3s-server \
"

RDEPENDS:${PN}-agent = " \
    packagegroup-oci \
    k3s-agent \
"
