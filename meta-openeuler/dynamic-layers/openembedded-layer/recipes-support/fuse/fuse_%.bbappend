# main bbfile: yocto-meta-openembedded/meta-filesystems/recipes-support/fuse/fuse_2.9.9.bb
OPENEULER_SRC_URI_REMOVE = "http https git"
OPENEULER_REPO_NAME = "fuse"

# version in openEuler
PV = "2.9.9"
S = "${WORKDIR}/fuse-${PV}"

# files, patches that come from openeuler
SRC_URI_append = " \
    file://fuse-${PV}.tar.gz \
    file://0001-libfuse-Assign-NULL-to-old-to-avoid-free-it-twice-52.patch \
    file://0002-util-ulockmgr_server.c-conditionally-define-closefro.patch \
    file://0003-add-fuse-test-dir.patch \
"
