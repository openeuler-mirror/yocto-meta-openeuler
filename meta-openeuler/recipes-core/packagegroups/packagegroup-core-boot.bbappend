#main bbfile: yocto-poky/meta/recipes-core/packagegroups/packagegroup-core-boot.bb

# we add kernel-img and kernel-vmlinux
RDEPENDS:${PN} += " \
    os-base \
    os-release \
"
# No rule to make target "Image" for x86-64, remove it
RDEPENDS:${PN}:remove:x86-64 = "kernel-img"

# * netbase's configuration files are included in os-base
#   to avoid extra download
#   we don't need grub-efi in non-live image
RDEPENDS:${PN}:remove =  " \
    netbase \
    ${@bb.utils.contains("MACHINE_FEATURES", "efi", "${EFI_PROVIDER} kernel", "", d)} \
"
