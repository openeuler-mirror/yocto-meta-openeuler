# the main bb file: yocto-poky/meta/recipes-devtools/e2fsprogs/e2fprogs_1.46.5.bb

PV = "1.47.0"

S = "${WORKDIR}/${BP}"
# delete patches from poky
SRC_URI:remove = " \
                file://0001-e2fsck-fix-last-mount-write-time-when-e2fsck-is-forc.patch \
                file://0010-libext2fs-add-sanity-check-to-extent-manipulation.patch \
                file://extents.patch \
                "

# add openeuler patches
SRC_URI += " \
    file://${BP}.tar.xz \
    file://0001-e2fsprogs-set-hugefile-from-4T-to-1T-in-hugefile-tes.patch \
    file://0002-e2fsck-exit-journal-recovery-when-find-EIO-ENOMEM-er.patch \
    file://0003-e2fsck-exit-journal-recovery-when-jounral-superblock.patch \
    file://0004-e2fsck-add-env-param-E2FS_UNRELIABLE_IO-to-fi.patch \
    file://0005-e2mmpstatus.8.in-detele-filesystem-can-be-UUID-or-LA.patch \
    file://0006-e2fsck-do-not-clean-up-file-acl-if-the-inode-is-trun.patch \
    file://0007-e2fsck-handle-level-is-overflow-in-ext2fs_extent_get.patch \
    file://0008-e2fsprogs-add-sw64.patch \
    file://0009-e2fsck-save-EXT2_ERROR_FS-flag-during-journal-replay.patch \
    file://0010-tune2fs-fuse2fs-debugfs-save-error-information-durin.patch \
    file://0011-mke2fs.conf-remove-metadata_csum_seed-and-orphan_fil.patch \
    file://0012-debugfs-fix-infinite-loop-while-dumping-the-journal.patch \
    file://0013-e4crypt-fix-spurious-Success-error-message.patch \
    file://0014-e2fsck-update-quota-accounting-after-directory-optim.patch \
    file://0015-e2fsck-update-quota-when-deallocating-a-bad-inode.patch \
    file://0016-fsck-fix-memory-leak-on-an-error-exit.patch \
"

SRC_URI[sha256sum] = "144af53f2bbd921cef6f8bea88bb9faddca865da3fbc657cc9b4d2001097d5db"

EXTRA_OECONF += "--enable-largefile"
