PV = "1.46.4"
S = "${WORKDIR}/${BPN}-${PV}"
# delete package from poky
SRC_URI_remove += "git://git.kernel.org/pub/scm/fs/ext2/e2fsprogs.git"

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
    file://0012-tests-skip-m_rootdir_acl-if-selinux-is-not-disabled.patch \
    file://0013-e2fsck-do-not-clean-up-file-acl-if-the-inode-is-trun.patch \
    file://0014-e2fsck-handle-level-is-overflow-in-ext2fs_extent_get.patch \
"
