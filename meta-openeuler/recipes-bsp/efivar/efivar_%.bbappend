# source bb: https://git.openembedded.org/openembedded-core/tree/meta/recipes-bsp/efivar/efivar_38.bb
PV = "38"

S = "${WORKDIR}/efivar-${PV}"

# note: 0002-fix-ld.patch and 0002-fix-ld2.patch is just for version 38
# this fix build err with glibc 2.38
# new 39 have fixed it and should remove this two patch
SRC_URI:prepend = " \
    file://efivar-${PV}.tar.bz2 \
    file://0001-Fix-the-march-issue-for-riscv64-and-sw_64.patch \
    file://0002-Fix-glibc-2.36-build-mount.h-conflicts.patch \
    file://dp_h-check-_ucs2size-in-format_ucs2.patch \
    file://backport-Fix-invalid-free-in-main.patch \
    file://add-loongarch64-support-for-efivar.patch \
    file://0002-fix-ld.patch \
    file://0002-fix-ld2.patch \
"

