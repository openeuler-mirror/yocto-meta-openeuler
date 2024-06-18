# main bbfile: yocto-poky/meta/recipes-extended/parted/parted_3.4.bb

# version in openEuler
PV = "3.5"

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
            file://0010-parted-remove-patch-which-modifid-cyl-size.patch \
            file://0011-libparted-Fix-potential-NULL-dereference-in-ped_disk.patch \
            "

# the patch check-vfat.patch will result in error
SRC_URI_remove = "file://check-vfat.patch \
"

SRC_URI[md5sum] = "336fde60786d5855b3876ee49ef1e6b2"
SRC_URI[sha256sum] = "4938dd5c1c125f6c78b1f4b3e297526f18ee74aa43d45c248578b1d2470c05a2"

S = "${WORKDIR}/${BP}"
