require xen-openeuler.inc

SRC_URI:append = " \
    file://acpi-arm-relax-MADT-GICC-entry-length-check-to-support-newer-ACPI-revisions.patch \
    file://xen-arm-Hide-PMU-registers-from-the-guest-when-the-vPMU-feature-is-disabled.patch \
"
