REALPV = "2.12"
PV = "2.12"

# Notice: openeuler's patches have many conflicts to patch, drop them.

OPENEULER_REPO_NAME = "grub2"

SRC_URI:prepend = "file://grub-${PV}.tar.xz \
"

SRC_URI[sha256sum] = "b79ea44af91b93d17cd3fe80bdae6ed43770678a9a5ae192ccea803ebb657ee1"

CVE_CHECK_IGNORE = ""

# The following difference are for building version 2.12
# ===============================================================

# for version 2.12, the following patches for version 2.06 are not needed
SRC_URI:remove = " \
    file://determinism.patch \
    file://CVE-2021-3981-grub-mkconfig-Restore-umask-for-the-grub.cfg.patch \
    file://0001-configure.ac-Use-_zicsr_zifencei-extentions-on-riscv.patch \
    file://video-Remove-trailing-whitespaces.patch \
    file://CVE-2021-3695-video-readers-png-Drop-greyscale-support-to-fix-heap.patch \
    file://CVE-2021-3696-video-readers-png-Avoid-heap-OOB-R-W-inserting-huff.patch \
    file://video-readers-jpeg-Abort-sooner-if-a-read-operation-.patch \
    file://video-readers-jpeg-Refuse-to-handle-multiple-start-o.patch \
    file://CVE-2021-3697-video-readers-jpeg-Block-int-underflow-wild-pointer.patch \
    file://CVE-2022-28733-net-ip-Do-IP-fragment-maths-safely.patch \
    file://CVE-2022-28734-net-http-Fix-OOB-write-for-split-http-headers.patch \
    file://CVE-2022-28734-net-http-Error-out-on-headers-with-LF-without-CR.patch \
    file://CVE-2022-28735-kern-efi-sb-Reject-non-kernel-files-in-the-shim_lock.patch \
    file://0001-font-Fix-size-overflow-in-grub_font_get_glyph_intern.patch \
    file://CVE-2022-2601.patch \
    file://CVE-2022-3775.patch \
    file://loader-efi-chainloader-Simplify-the-loader-state.patch \
    file://commands-boot-Add-API-to-pass-context-to-loader.patch \
    file://CVE-2022-28736-loader-efi-chainloader-Use-grub_loader_set_ex.patch \
"

SRC_URI[sha256sum] = "b30919fa5be280417c17ac561bb1650f60cfb80cc6237fa1e2b6f56154cb9c91"

CVE_STATUS[CVE-2019-14865] = "not-applicable-platform: applies only to RHEL"
CVE_STATUS[CVE-2021-46705] = "not-applicable-platform: Applies only to SUSE"
CVE_STATUS[CVE-2023-4001]  = "not-applicable-platform: Applies only to RHEL/Fedora"
CVE_STATUS[CVE-2024-1048]  = "not-applicable-platform: Applies only to RHEL/Fedora"
CVE_STATUS[CVE-2023-4692]  = "cpe-incorrect: Fixed in version 2.12 already"
CVE_STATUS[CVE-2023-4693]  = "cpe-incorrect: Fixed in version 2.12 already"

GRUB_COMPATIBLE_HOST = '(x86_64.*|i.86.*|arm.*|aarch64.*|riscv.*)-(linux.*|freebsd.*)'
COMPATIBLE_HOST = "${GRUB_COMPATIBLE_HOST}"
# Grub doesn't support hard float toolchain and won't be able to forcefully
# disable it on some of the target CPUs. See 'configure.ac' for
# supported/unsupported CPUs in hardfp.
COMPATIBLE_HOST:armv7a = "${@'null' if bb.utils.contains('TUNE_CCARGS_MFLOAT', 'hard', True, False, d) else d.getVar('GRUB_COMPATIBLE_HOST')}"
COMPATIBLE_HOST:armv7ve = "${@'null' if bb.utils.contains('TUNE_CCARGS_MFLOAT', 'hard', True, False, d) else d.getVar('GRUB_COMPATIBLE_HOST')}"

do_configure:prepend() {
    # Remove in next version.
	# See: https://git.savannah.gnu.org/cgit/grub.git/commit/?id=b835601c7639ed1890f2d3db91900a8506011a8e
	echo "depends bli part_gpt" > ${S}/grub-core/extra_deps.lst
}
