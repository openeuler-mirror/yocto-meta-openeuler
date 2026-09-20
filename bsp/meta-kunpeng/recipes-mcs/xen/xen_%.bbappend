# kp920: skip the x86-only PCI option ROM scan on ARM - it serves no
# purpose there and has been observed to wedge faulty devices before
# the guest kernel and its drivers load.
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append:kp920 = " file://0001-xen-skip-pci-rom-scan-on-arm.patch"
# GICv3 ITS: dom0 PCI MSI depends on it; without ITS every MSI
# allocation in dom0 fails and the hns3 NIC never comes up.
SRC_URI:append:kp920 = " file://xen-its-kp920.cfg"
