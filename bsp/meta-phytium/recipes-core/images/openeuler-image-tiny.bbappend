#fix no efi in openeuler-image-tiny wic image
EFI_PROVIDER ??= "grub-efi"

RDEPENDS:${PN}:append =  " \
    ${@bb.utils.contains("MACHINE_FEATURES", "efi", "${EFI_PROVIDER}", "", d)} \
"
