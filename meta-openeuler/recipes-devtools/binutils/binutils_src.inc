PV = "2.37"
S = "${WORKDIR}/${BPN}-${PV}"

# apply package source and patches from openeuler
SRC_URI = " \
    file://binutils-2.37.tar.xz \
    file://binutils-2.20.51.0.2-libtool-lib64.patch \
    file://export-demangle.h-in-devel-package.patch \
    file://binutils-2.22.52.0.4-no-config-h-check.patch \
    file://binutils-2.27-aarch64-ifunc.patch \
    file://CVE-2019-1010204.patch \
    file://Fix-a-potential-use-of-an-uninitialised-value-in-the.patch \
    file://backport-CVE-2021-45078.patch \
    file://backport-0001-CVE-2021-42574.patch \
    file://backport-0002-CVE-2021-42574.patch \
    file://backport-0003-CVE-2021-42574.patch \
    file://bfd-Close-the-file-descriptor-if-there-is-no-archive.patch \
    file://binutils-AArch64-EFI.patch \
    file://backport-0001-PR28391-strip-objcopy-preserve-dates-.a-cannot-set-t.patch \
    file://0001-x86-Add-int1-as-one-byte-opcode-0xf1.patch \
    file://0002-x86-drop-OP_Mask.patch \
    file://0003-x86-correct-VCVT-U-SI2SD-rounding-mode-handling.patch \
    file://0004-x86-64-generalize-OP_G-s-EVEX.R-handling.patch \
    file://0005-x86-64-properly-bounds-check-bnd-N-in-OP_G.patch \
    file://0006-x86-fold-duplicate-register-printing-code.patch \
    file://0007-x86-fold-duplicate-code-in-MOVSXD_Fixup.patch \
    file://0008-x86-correct-EVEX.V-handling-outside-of-64-bit-mode.patch \
    file://0009-x86-drop-vex_mode-and-vex_scalar_mode.patch \
    file://0010-x86-fold-duplicate-vector-register-printing-code.patch \
    file://0011-x86-drop-xmm_m-b-w-d-q-_mode.patch \
    file://0012-x86-drop-vex_scalar_w_dq_mode.patch \
    file://0013-x86-drop-dq-b-d-_mode.patch \
    file://0014-x86-express-unduly-set-rounding-control-bits-in-disa.patch \
    file://0015-x86-Simplify-check-for-distinct-TMM-register-operand.patch \
    file://0016-PATCH-1-2-Enable-Intel-AVX512_FP16-instructions.patch \
    file://0017-PATCH-2-2-Add-tests-for-Intel-AVX512_FP16-instructio.patch \
    file://0018-x86-ELF-fix-.tfloat-output.patch \
    file://0019-x86-ELF-fix-.ds.x-output.patch \
    file://0020-x86-ELF-fix-.tfloat-output-with-hex-input.patch \
    file://0021-x86-introduce-.hfloat-directive.patch \
    file://0022-x86-Avoid-abort-on-invalid-broadcast.patch \
    file://0023-x86-Put-back-3-aborts-in-OP_E_memory.patch \
    file://0024-x86-Print-bad-on-invalid-broadcast-in-OP_E_memory.patch \
    file://0025-x86-Terminate-mnemonicendp-in-swap_operand.patch \
    file://0026-opcodes-Make-i386-dis.c-thread-safe.patch \
    file://0027-x86-reduce-AVX512-FP16-set-of-insns-decoded-through-.patch \
    file://0028-x86-reduce-AVX512-FP-set-of-insns-decoded-through-ve.patch \
    file://0029-x86-consistently-use-scalar_mode-for-AVX512-FP16-sca.patch \
    file://backport-CVE-2022-38126.patch \
    file://backport-0001-texi2pod.pl-add-no-op-no-split-option-support-PR2814.patch \
    file://backport-AArch64-Add-support-for-AArch64-EFI-efi-aarch64.patch \
    file://backport-Add-support-for-AArch64-EFI-efi-aarch64.patch \
    file://backport-don-t-over-align-file-positions-of-PE-executable-sec.patch \
    file://backport-PR28186-SEGV-elf.c-7991-30-in-_bfd_elf_fixup_group_sections.patch \
    file://backport-PR28422-build_id-use-after-free.patch \
    file://backport-PR28540-segmentation-fault-on-NULL-byte_get.patch \
    file://Fix-gold-relocation-offset-and-adrp-signed-shife.patch \
    file://CVE-2022-47008.patch \
    file://backport-CVE-2022-47011.patch \
    file://backport-CVE-2022-47696.patch \
    file://backport-CVE-2021-46174.patch \
    file://backport-CVE-2023-1972.patch \
    file://backport-CVE-2022-48064.patch \
    file://backport-CVE-2022-4285.patch \
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
