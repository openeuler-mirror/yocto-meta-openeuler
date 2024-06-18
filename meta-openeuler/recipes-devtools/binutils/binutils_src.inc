PV = "2.37"
S = "${WORKDIR}/${BPN}-${PV}"

# apply package source and patches from openeuler
SRC_URI = " \
    file://binutils-2.37.tar.xz \
    file://backport-CVE-2019-1010204.patch \
    file://backport-Fix-a-potential-use-of-an-uninitialised-value-in-the.patch \
    file://backport-CVE-2021-45078.patch \
    file://backport-0001-CVE-2021-42574.patch \
    file://backport-0002-CVE-2021-42574.patch \
    file://backport-0003-CVE-2021-42574.patch \
    file://backport-bfd-Close-the-file-descriptor-if-there-is-no-archive.patch \
    file://backport-binutils-AArch64-EFI.patch \
    file://backport-PR28391-strip-objcopy-preserve-dates-.a-cannot-set-t.patch \
    file://backport-CVE-2022-38126.patch \
    file://backport-texi2pod.pl-add-no-op-no-split-option-support-PR2814.patch \
    file://backport-AArch64-Add-support-for-AArch64-EFI-efi-aarch64.patch \
    file://backport-Add-support-for-AArch64-EFI-efi-aarch64.patch \
    file://backport-don-t-over-align-file-positions-of-PE-executable-sec.patch \
    file://backport-PR28186-SEGV-elf.c-7991-30-in-_bfd_elf_fixup_group_sections.patch \
    file://backport-PR28422-build_id-use-after-free.patch \
    file://backport-PR28540-segmentation-fault-on-NULL-byte_get.patch \
    file://backport-CVE-2022-47008.patch \
    file://backport-CVE-2022-47011.patch \
    file://backport-CVE-2022-47696.patch \
    file://backport-CVE-2021-46174.patch \
    file://backport-CVE-2023-1972.patch \
    file://backport-CVE-2022-48064.patch \
    file://backport-CVE-2022-4285.patch \
    file://backport-CVE-2022-38533.patch \
    file://binutils-2.20.51.0.2-libtool-lib64.patch \
    file://export-demangle.h-in-devel-package.patch \
    file://binutils-2.22.52.0.4-no-config-h-check.patch \
    file://binutils-2.27-aarch64-ifunc.patch \
    file://Fix-gold-relocation-offset-and-adrp-signed-shife.patch \
    file://aarch64-add-l4-instruction.patch \
"

# apply used patches from poky
SRC_URI += " \
    file://0005-Point-scripts-location-to-libdir.patch \
"

SRC_URI[sha256sum] = "820d9724f020a3e69cb337893a0b63c2db161dadcb0e06fc11dc29eb1e84a32c"

do_configure_prepend_class-target () {
    # fix Can't locate Autom4te/ChannelDefs.pm in @INC (you may need to install the Autom4te::ChannelDefs module) (@INC contains: /build/tmp/work/*/binutils/2.37-r0/recipe-sysroot-native/usr/share/autoconf ...
    # autoconf is installed at buildtool-bar, not build autoconf-native, so need to set autom4te_perllibdir or modify default value in gnu-config
    if [ ! -z "${OPENEULER_NATIVESDK_SYSROOT}" ];then
        export autom4te_perllibdir="${OPENEULER_NATIVESDK_SYSROOT}/usr/share/autoconf"
    fi
}

# bfd_stdint.h has been removed in favor of using stdint.h in new version
# delete the two function below after upgrade to new poky
do_install_prepend () {
        mkdir -p ${D}${includedir}
        touch ${D}${includedir}/bfd_stdint.h
}
do_install_append () {
        rm -f ${D}${includedir}/bfd_stdint.h
}
