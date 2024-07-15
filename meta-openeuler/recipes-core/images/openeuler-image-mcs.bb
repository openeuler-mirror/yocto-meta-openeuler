SUMMARY = "A small image just capable of openEuler Embedded's mcs feature"

require openeuler-image-common.inc

# by default, mcs image needs a modified device tree for reserved resources
inherit features_check
REQUIRED_DISTRO_FEATURES = "mcs"

# Only inherit the qemuboot classes when building for a qemu machine
QB_QEMU_CLASSES = ""
QB_QEMU_CLASSES:append:qemuall = "${@bb.utils.contains('DISTRO_FEATURES', 'xen', ' qemuboot-xen-defaults qemuboot-xen-dtb', '', d)}"
QB_QEMU_CLASSES:append:qemuall = "${@bb.utils.contains('MCS_FEATURES', 'openamp', ' qemuboot-mcs-dtb', '', d)}"
QB_MEM = "-m 1048"
inherit ${QB_QEMU_CLASSES}

IMAGE_FEATURES:remove = "weston"

# basic packages required, e.g., boot, ssh ,debug
# overwrite this variable, or IMAGE_INSTALL was standard packages in openeuler-image-common.inc file
IMAGE_INSTALL = " \
packagegroup-core-boot \
packagegroup-kernel-modules \
packagegroup-openssh \
packagegroup-mcs \
"

python () {
    machine = d.getVar('MACHINE').split()

    # qemu-aarch64 related handling
    if 'qemu-aarch64' in machine:
        mcs_features = d.getVar('MCS_FEATURES').split()
        if 'openamp' in mcs_features:
            d.setVar('QB_KERNEL_CMDLINE_APPEND', 'maxcpus=3')
            # IMAGE_NAME variable depends on DATETIME variable, result in error:
            # The metadata is not deterministic and this needs to be fixed
            # this is a workaround to fix:
            # not build soft link, remove IMAGE_VERSION_SUFFIX from QB_DTB
            d.setVar('QB_DTB', d.getVar('IMAGE_LINK_NAME') + ".qemuboot.dtb")
            d.setVar('QB_DTB_LINK', d.getVar('IMAGE_LINK_NAME') + ".qemuboot.dtb")
        elif 'jailhouse' in mcs_features:
            d.setVar('QB_MACHINE', '-machine virt,gic-version=3,virtualization=on,its=off')
            d.setVar('QB_KERNEL_CMDLINE_APPEND', 'mem=750M')
}
