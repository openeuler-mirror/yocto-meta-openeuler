# main bbfile: yocto-poky/meta/recipes-kernel/kexec/kexec-tools_2.0.21.bb

# kexec-tools version in openEuler
PV = "2.0.23"

# Use the source packages from openEuler and remove conflicting patches
SRC_URI_remove = "${KERNELORG_MIRROR}/linux/utils/kernel/kexec/kexec-tools-${PV}.tar.gz \
                  file://0001-arm64-kexec-disabled-check-if-kaslr-seed-dtb-propert.patch \
                  "
# don't patch fix-add-64-bit-loongArch-support-1.patch and sw_64.patch
# fix-add-64-bit-loongArch-support-2.patch and makedumpfile-1.7.0-sw.patch are for makedumpfile
SRC_URI_prepend = "file://kexec-tools-${PV}.tar.xz \
                file://arm64-support-more-than-one-crash-kernel-regions.patch \
                file://kexec-Add-quick-kexec-support.patch \
                file://kexec-Quick-kexec-implementation-for-arm64.patch \
                file://arm64-crashdump-deduce-paddr-of-_text-based-on-kerne.patch \
                file://arm64-make-phys_offset-signed.patch \
                file://arm64-crashdump-unify-routine-to-get-page_offset.patch \
                file://arm64-read-VA_BITS-from-kcore-for-52-bits-VA-kernel.patch \
                file://arm64-fix-PAGE_OFFSET-calc-for-flipped-mm.patch \
                "

SRC_URI[md5sum] = "483f3d35de59b3fffeab10d386cb7364"
SRC_URI[sha256sum] = "aa63cd6c7dd95b06ceba6240a7fdc6792789cada75a655e6714987175224241b"
