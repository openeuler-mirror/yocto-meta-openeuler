SUMMARY = "packages for random daemon"
inherit packagegroup

PR = "r1"

PACKAGES = "${PN}"

# According to DISTRO_FEATURES:
#  - if rng-tools is used, rng-tools will be included
#  - if haveged is used, haveged will be included
RDEPENDS:${PN} = " \
${@bb.utils.contains('DISTRO_FEATURES', 'rng-tools', 'rng-tools', '', d)} \
${@bb.utils.contains('DISTRO_FEATURES', 'haveged', 'haveged', '', d)} \
"

