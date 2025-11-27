DESCRIPTION = "package group for simple custom container tools including nerdctl, containerd, and dependencies."
SUMMARY = "custom lightweight containerd-based toolkits"
inherit packagegroup features_check

REQUIRED_DISTRO_FEATURES += "systemd"
PACKAGES = " \
    ${PN} \
"


RDEPENDS:${PN} = " \
    virtual-containerd \
    virtual-runc \
    oci-systemd-hook \
    oci-runtime-tools \
    oci-image-tools \
    bridge-utils \
    ${@bb.utils.contains('BUILD_GIT_NERDCTL', '', '', 'nerdctl', d)} \
    "

RRECOMMENDS:${PN} = " \
    kernel-module-veth \
    kernel-module-bridge \
    kernel-module-br-netfilter \
    "
