PV = "1.46.4"

S = "${WORKDIR}/${BPN}-${PV}"
# delete package from poky
SRC_URI_remove += "git://git.kernel.org/pub/scm/fs/ext2/e2fsprogs.git \
                git://git.kernel.org/pub/scm/fs/ext2/e2fsprogs.git;branch=master \
                file://0001-e2fsck-fix-last-mount-write-time-when-e2fsck-is-forc.patch \
                "

SRC_URI[sha256sum] = "b11042533c1b1dcf17512f0da48e05b0c573dada1dd8b762864d10f4dc399713"

# add openeuler patches
SRC_URI += " \
    file://e2fsprogs-${PV}.tar.xz \
    file://0001-e2fsprogs-set-hugefile-from-4T-to-1T-in-hugefile-tes.patch \
    file://0002-libss-add-newer-libreadline.so.8-to-dlopen-path.patch \
    file://0003-tests-update-expect-files-for-f_mmp_garbage.patch \
    file://0004-tests-update-expect-files-for-f_large_dir-and-f_larg.patch \
    file://0005-resize2fs-resize2fs-disk-hardlinks-will-be-error.patch \
    file://0006-e2fsck-exit-journal-recovery-when-find-EIO-ENOMEM-er.patch \
    file://0007-e2fsck-exit-journal-recovery-when-jounral-superblock.patch \
    file://0008-e2fsck-add-env-param-E2FS_UNRELIABLE_IO-to-fi.patch \
    file://0009-e2mmpstatus.8.in-detele-filesystem-can-be-UUID-or-LA.patch \
    file://0010-tests-update-expect-file-for-u_direct_io.patch \
    file://0011-libext2fs-don-t-old-the-CACHE_MTX-while-doing-I-O.patch \
    file://0012-tests-fix-ACL-printing-tests.patch \
    file://0013-e2fsck-do-not-clean-up-file-acl-if-the-inode-is-trun.patch \
    file://0014-e2fsck-handle-level-is-overflow-in-ext2fs_extent_get.patch \
    file://0015-libext2fs-add-sanity-check-to-extent-manipulation.patch \
    file://0016-e2fsprogs-add-sw64.patch \
    file://0017-tune2fs-do-not-change-j_tail_sequence-in-journal-sup.patch \
    file://0018-debugfs-teach-logdump-the-n-num_trans-option.patch \
    file://0019-tune2fs-fix-tune2fs-segfault-when-ext2fs_run_ext3_jo.patch \
    file://0020-tune2fs-tune2fs_main-should-return-rc-when-some-erro.patch \
    file://0021-tune2fs-exit-directly-when-fs-freed-in-ext2fs_run_ext3_journal.patch \
    file://0022-unix_io.c-fix-deadlock-problem-in-unix_write_blk64.patch \
    file://0023-debugfs-fix-repeated-output-problem-with-logdump-O-n.patch \
    file://0024-tune2fs-check-return-value-of-ext2fs_mmp_update2-in-.patch \
    file://0025-mmp-fix-wrong-comparison-in-ext2fs_mmp_stop.patch \
    file://0026-misc-fsck.c-Processes-may-kill-other-processes.patch \
"
