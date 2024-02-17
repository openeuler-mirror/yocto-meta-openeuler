# main bbfile: yocto-meta-openembedded/meta-filesystems/recipes-support/fuse/fuse_2.9.9.bb
# version in openEuler
PV = "2.9.9"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI:remove = " \
           file://gold-unversioned-symbol.patch \
           file://aarch64.patch \
           file://0001-fuse-fix-the-return-value-of-help-option.patch \
           file://fuse2-0007-util-ulockmgr_server.c-conditionally-define-closefro.patch \
"

# files, patches that come from openeuler
SRC_URI:prepend = " \
    file://${BP}.tar.gz \
    file://0000-fix-compile-error-because-of-ns-colliding.patch \
    file://0001-libfuse-Assign-NULL-to-old-to-avoid-free-it-twice-52.patch \
    file://0002-util-ulockmgr_server.c-conditionally-define-closefro.patch \
    file://0003-add-fuse-test-dir.patch \
"
