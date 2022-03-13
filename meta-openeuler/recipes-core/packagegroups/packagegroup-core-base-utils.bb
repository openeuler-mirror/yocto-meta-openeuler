DESCRIPTION = "packages to provide base utils"
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
