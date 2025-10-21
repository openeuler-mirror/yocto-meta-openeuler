DESCRIPTION = "package group for simple custom container tools including nerdctl, containerd, and dependencies."
SUMMARY = "custom lightweight containerd-based toolkits"
inherit packagegroup features_check

REQUIRED_DISTRO_FEATURES += "systemd"
# it is not recommended to package this simple lightweight containerd packagegroup together with isulad
CONFLICT_DISTRO_FEATURES = "isulad"
PACKAGES = " \
    ${PN} \
"

# TODO: cni compatibility
RDEPENDS:${PN} = " \
    virtual-containerd \
    virtual-runc \
    oci-systemd-hook \
    oci-runtime-tools \
    oci-image-tools \
    nerdctl \
    bridge-utils \
    "

RRECOMMENDS:${PN} = " \
    cni \
    kernel-module-veth \
    kernel-module-bridge \ 
    kernel-module-br-netfilter \
    kernel-module-ebtables \
    kernel-module-nf-nat \
    kernel-module-nf-conntrack-netlink \
    kernel-module-xt-comment \
    kernel-module-xt-statistic \
    kernel-module-xt-multiport \
    kernel-module-xt-addrtype \
    kernel-module-xt-masquerade \
"
