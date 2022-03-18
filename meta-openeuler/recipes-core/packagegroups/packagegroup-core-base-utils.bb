DESCRIPTION = "packages to provide base utils"

#
# packages which content depend on MACHINE_FEATURES need to be MACHINE_ARCH
#
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PACKAGES = "${PN}"

RDEPENDS_${PN} = "\
audit \
auditd \
audispd-plugins \
cracklib \
libpwquality \
libpam \
packagegroup-pam-plugins \
shadow \
shadow-securetty \
bash \
"

RDEPENDS_${PN}_append_arm += "kernel-module-unix"
