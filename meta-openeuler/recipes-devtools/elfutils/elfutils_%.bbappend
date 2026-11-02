# the main bbfile: yocto-poky/meta/recipes-devtools/elfutils/elfutils_0.186.bb
PV = "0.190"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# the path removed in 0.187
SRC_URI:remove = " \
    file://0001-debuginfod-fix-compilation-on-platforms-without-erro.patch \
    file://0001-debuginfod-debuginfod-client.c-use-long-for-cache-ti.patch \
    file://0001-libasm-may-link-with-libbz2-if-found.patch \
"

# NOTE (workaround): upstream's elfutils-0.190.tar.bz2 in the src-openeuler
# repo is actually gzip-compressed data despite the .tar.bz2 name (bad magic
# for bzip2, verified with `file`). bitbake picks the unpack command by suffix,
# so mark it unpack=0 and unpack by real format below; drop the workaround
# once upstream fixes the archive format/filename.
# add patches from openeuler
SRC_URI:append = " \
    file://${BP}.tar.bz2;unpack=0 \
    file://Fix-segfault-in-eu-ar-m.patch \
    file://Fix-issue-of-moving-files-by-ar-or-br.patch \
    file://CVE-2024-25260.patch \
    file://Backport-fix-handling-of-corefiles-with-non-contiguous-segments.patch \
    file://add-sw_64-support.patch \
    file://backport-fix-riscv64-return-value-location-retrieval-implementation.patch \
    file://backport-CVE-2025-1352.patch \
    file://backport-CVE-2025-1365.patch \
    file://backport-CVE-2025-1371.patch \
    file://backport-CVE-2025-1372.patch \
    file://backport-CVE-2025-1376.patch \
    file://backport-CVE-2025-1377.patch \
    file://backport-libelf-fix-OOB-read-in-elf_getarsym-32-bit-archive-index-count.patch \
    file://backport-libelf-Bounds-check-archive-symbol-index-count-on-the-mmap-path.patch \
    file://backport-libelf-Correct-the-size-of-the-in-memory-datastructure-off-by-one.patch \
    file://backport-tests-Add-ar-header-only-test-to-ar-getarsym-mem.patch \
"

# unpack ${BP}.tar.bz2 by its real format (gzip), see NOTE above.
# NOTE: do_unpack is a python wrapper in this poky version, so the append
# must be python syntax.
python do_unpack:append() {
    import subprocess
    workdir = d.getVar('WORKDIR')
    src = os.path.join(workdir, '%s.tar.bz2' % d.getVar('BP'))
    if subprocess.call('bzip2 -t %s >/dev/null 2>&1' % src, shell=True) == 0:
        cmd = 'tar -xjf %s -C %s' % (src, workdir)
    else:
        cmd = 'tar -xzf %s -C %s' % (src, workdir)
    bb.note('elfutils tarball unpack: %s' % cmd)
    subprocess.check_call(cmd, shell=True)
}

SRC_URI[sha256sum] = "f285fc1c8be8fce23426a9085716b27ee1e65fbd599509a03a6a7f654c663872"

LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504 \
                    file://debuginfod/debuginfod-client.c;endline=27;md5=7eb69ae4d5654e590c840538256a7bfe \
                    "

ASSUME_PROVIDE_PKGS = "elfutils-libelf-devel"
