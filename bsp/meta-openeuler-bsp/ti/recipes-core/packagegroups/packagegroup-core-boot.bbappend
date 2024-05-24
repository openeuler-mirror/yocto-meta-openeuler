# kernel need below files to boot
RDEPENDS:${PN} += " \
    kernel-custom-dtb \
    kernel-image-fitimage \
    kernel-image-image \
"

RDEPENDS:${PN}:remove= " \
    kernel-img \
"
