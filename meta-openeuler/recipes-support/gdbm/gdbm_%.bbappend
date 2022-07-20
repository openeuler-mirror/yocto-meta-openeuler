# main bbfile: yocto-poky/meta/recipes-support/gdbm/gdbm_1.19.bb

# version in openEuler
PV = "1.22"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
            ${GNU_MIRROR}/gdbm/gdbm-${PV}.tar.gz \
            "

SRC_URI += " \
        file://${BPN}-${PV}.tar.gz \
        "

SRC_URI[tarball.md5sum] = "0bbd38f12656e4728e2f7c4708aec014"
SRC_URI[tarball.sha256sum] = "f366c823a6724af313b6bbe975b2809f9a157e5f6a43612a72949138d161d762"

