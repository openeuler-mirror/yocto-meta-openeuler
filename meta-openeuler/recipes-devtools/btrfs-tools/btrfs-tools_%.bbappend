PV = "6.6.3"

OPENEULER_REPO_NAME = "btrfs-progs"

# remove poky attr
SRC_URI:remove = "\
           file://0001-Add-a-possibility-to-specify-where-python-modules-ar.patch \
           "

# openeuler source
SRC_URI:prepend = "file://btrfs-progs-v${PV}.tar.xz \
            file://0001-fix-exclusive-op-enqueue-timeout.patch \
            file://0002-subvolume-fix-return-value-when-the-target-exists.patch \
            file://0003-fix-memory-leak-on-exit-path-in-table-vprintf.patch \
            file://0004-btrfs-progs-scrub-status-only-report-limits-if-at-le.patch \
            file://0005-btrfs-progs-fix-freeing-of-device-after-error-in-btr.patch \
            file://0006-fix-double-free-on-error-in-read_raid56.patch \
            file://0007-btrfs-progs-fi-show-canonicalize-path-when-using-blk.patch \
            file://0008-btrfs-progs-tune-fix-the-missing-close-of-filesystem.patch \
            file://0009-btrfs-progs-error-out-immediately-if-an-unknown-back.patch \
"

S = "${WORKDIR}/btrfs-progs-v${PV}"

# attr from 6.5.3.bb
DEPENDS = "lzo util-linux zlib"
PACKAGECONFIG[manpages] = "--enable-documentation, --disable-documentation, python3-sphinx-native"
PACKAGECONFIG[lzo] = "--enable-lzo,--disable-lzo,lzo"
# Fix: QA Issue: babeltrace: Files/directories were installed but not shipped in any package
FILES:${PN} += "/usr/lib/"
