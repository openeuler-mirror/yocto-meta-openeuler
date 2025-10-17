DESCRIPTION = "package group for simple custom container tools including nerdctl, containerd, and dependencies."
SUMMARY = "custom lightweight containerd-based toolkits"
inherit packagegroup features_check

REQUIRED_DISTRO_FEATURES += "systemd"
# it is not recommended to package this simple lightweight containerd packagegroup together with isulad
CONFLICT_DISTRO_FEATURES = "isulad"
PACKAGES = " \
    ${PN} \
"

# TODO: version migration for containerd (to >1.7.1)
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
