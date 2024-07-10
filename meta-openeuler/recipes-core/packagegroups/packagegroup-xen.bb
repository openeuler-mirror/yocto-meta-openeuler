SUMMARY = "packages for xen dom0"
PACKAGE_ARCH = "${MACHINE_ARCH}"
inherit packagegroup

PR = "r1"

PACKAGES = "${PN}"

XEN_KERNEL_MODULES ?= "kernel-module-xen-blkback kernel-module-xen-gntalloc \
                       kernel-module-xen-gntdev kernel-module-xen-netback kernel-module-xen-wdt \
                       ${@bb.utils.contains('MACHINE_FEATURES', 'pci', "${XEN_PCIBACK_MODULE}", '', d)} \
                       ${@bb.utils.contains('MACHINE_FEATURES', 'acpi', '${XEN_ACPI_PROCESSOR_MODULE}', '', d)} \
                      "

RDEPENDS:${PN} = " \
    ${XEN_KERNEL_MODULES} \
    xen-tools \
    "

# The hypervisor may not be within the dom0 filesystem image but at least
# ensure that it is deployable:
DEPENDS = " \
    xen \
    "

# Networking for HVM-mode guests (x86/64 only) requires the tun kernel module
RDEPENDS:${PN}:append:x86-64 = " kernel-module-tun"

# Linux kernel option CONFIG_XEN_PCIDEV_BACKEND depends on X86
XEN_PCIBACK_MODULE = ""
XEN_PCIBACK_MODULE:x86    = "kernel-module-xen-pciback"
XEN_PCIBACK_MODULE:x86-64 = "kernel-module-xen-pciback"
XEN_ACPI_PROCESSOR_MODULE = ""
XEN_ACPI_PROCESSOR_MODULE:x86    = "kernel-module-xen-acpi-processor"
XEN_ACPI_PROCESSOR_MODULE:x86-64 = "kernel-module-xen-acpi-processor"
