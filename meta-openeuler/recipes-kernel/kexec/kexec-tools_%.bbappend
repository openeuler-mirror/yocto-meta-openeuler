# main bbfile: yocto-poky/meta/recipes-kernel/kexec/kexec-tools_2.0.21.bb

# kexec-tools version in openEuler
PV = "2.0.23"

# Use the source packages from openEuler and remove conflicting patches
SRC_URI_remove = "${KERNELORG_MIRROR}/linux/utils/kernel/kexec/kexec-tools-${PV}.tar.gz \
                  file://0001-arm64-kexec-disabled-check-if-kaslr-seed-dtb-propert.patch \
                  "
SRC_URI_prepend = "file://kexec-tools/kexec-tools-${PV}.tar.xz "

SRC_URI += "file://kexec-tools/arm64-support-more-than-one-crash-kernel-regions.patch \
            file://kexec-tools/kexec-Add-quick-kexec-support.patch \
            file://kexec-tools/kexec-Quick-kexec-implementation-for-arm64.patch \
            file://kexec-tools/arm64-crashdump-deduce-paddr-of-_text-based-on-kerne.patch \
            "

SRC_URI[md5sum] = "483f3d35de59b3fffeab10d386cb7364"
SRC_URI[sha256sum] = "aa63cd6c7dd95b06ceba6240a7fdc6792789cada75a655e6714987175224241b"
