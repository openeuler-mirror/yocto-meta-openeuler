PACKAGES:remove = "\
    packagegroup-container \
    packagegroup-lxc \
    ${@bb.utils.contains('DISTRO_FEATURES', 'seccomp ipv6', \
                         'packagegroup-podman', '', d)} \
    "
