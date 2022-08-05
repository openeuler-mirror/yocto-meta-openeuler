# main bbfile: yocto-poky/meta/recipes-extended/parted/parted_3.4.bb

# version in openEuler
PV = "3.4"

# Use the source packages from openEuler
SRC_URI_remove = " \
            ${GNU_MIRROR}/parted/parted-${PV}.tar.xz \
            "
SRC_URI += "file://parted-${PV}.tar.xz \
            file://0001-add-support-of-gpt_sync_mbr.patch \
            file://0002-Add-extra-judgment-for-a-partition-created-success.patch \
            file://0003-bugfix-parted-fix-failure-of-mklabel-gpt_sync_mbr.patch \
            file://0004-hfsplus_btree_search-free-node-when-hfsplus_file_rea.patch \
            file://0005-amiga_read-need-free-part-and-partition-when-constra.patch \
            file://0006-scsi_get_product_info-fix-memleak-and-avoid-to-use-N.patch \
            file://0007-fat_op_context_new-free-ctx-remap-and-goto-correct-l.patch \
            file://0008-hfsplus_cache_from_extent-fix-memleak.patch \
            file://0009-fat_clobber-set-boot_sector-NULL-and-free-boot_secto.patch \
            "

SRC_URI[md5sum] = "357d19387c6e7bc4a8a90fe2d015fe80"
SRC_URI[sha256sum] = "e1298022472da5589b7f2be1d5ee3c1b66ec3d96dfbad03dc642afd009da5342"

S = "${WORKDIR}/${BP}"
