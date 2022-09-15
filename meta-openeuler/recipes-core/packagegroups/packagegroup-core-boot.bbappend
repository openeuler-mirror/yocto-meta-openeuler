#main bbfile: yocto-poky/meta/recipes-core/packagegroups/packagegroup-core-boot.bb

# we add kernel-img and kernel-vmlinux
RDEPENDS_${PN} += " \
    kernel \
    kernel-img \
    kernel-image \
    kernel-vmlinux \
    os-base \
    os-release \
"
# No rule to make target "Image" for x86-64, remove it
RDEPENDS_${PN}_remove_x86-64 += "kernel-img"

# * netbase's configuration files are included in os-base
#   to avoid extra download
#   we don't neet grub-efi in non-live iamge
RDEPENDS_${PN}_remove =  " \
    netbase \
    ${@bb.utils.contains("MACHINE_FEATURES", "efi", "${EFI_PROVIDER} kernel", "", d)} \
"
