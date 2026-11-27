require xen-openeuler.inc

SRC_URI:append = " \
    file://acpi-arm-relax-MADT-GICC-entry-length-check-to-support-newer-ACPI-revisions.patch \
"
