# main bbfile: yocto-poky/meta/recipes-support/gdbm/gdbm_1.19.bb

# version in openEuler
PV = "1.23"

# files, patches can't be applied in openeuler or conflict with openeuler
# ptest.patch, patch-fuzz warning
SRC_URI:remove = " \
            ${GNU_MIRROR}/gdbm/gdbm-${PV}.tar.gz \
            file://ptest.patch \
            "

SRC_URI += " \
        file://${BPN}-${PV}.tar.gz \
        file://Fix-binary-dump-format-for-key-and-or-data-of-zero-s.patch \
        file://gdbm_dump-fix-command-line-error-detection.patch \
        file://Fix-location-tracking-in-gdbmtool.-Fix-the-recover-c.patch \
        file://Fix-coredump-in-gdbmtool-history-command.patch \
        file://Fix-semantics-of-gdbm_load-r.patch \
        file://Improve-handling-of-u-in-gdbm_load.patch \
        file://Fix-allocated-memory-not-released.patch \
        file://Restore-accidentally-removed-parameter-and-New-macro.patch \
        "

SRC_URI[tarball.md5sum] = "0bbd38f12656e4728e2f7c4708aec014"
SRC_URI[tarball.sha256sum] = "f366c823a6724af313b6bbe975b2809f9a157e5f6a43612a72949138d161d762"
