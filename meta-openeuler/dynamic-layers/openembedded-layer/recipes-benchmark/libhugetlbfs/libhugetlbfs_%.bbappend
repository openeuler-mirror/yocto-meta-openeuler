# main bbfile: meta-oe/recipes-benchmark/libhugetlbfs/libhugetlbfs_git.bb?h=hardknott

OPENEULER_SRC_URI_REMOVE = "git"

# remove patch conflicting with openeuler
SRC_URI_remove = "file://0001-tests-makefile-Append-CPPFLAGS-rather-then-override.patch \
"

SRC_URI_prepend = "file://${BP}.tar.gz \
           file://0000-build_flags.patch \
           file://Disable-hugepage-backed-malloc-if-__morecore-is-not-.patch \
           file://libhugetlbfs-make-cflags.patch \
"

S = "${WORKDIR}/${BP}"

SRC_URI[sha256sum] = "b70672f1e807c61b7eb3adf41c1903b42917951f2e7f8aef6821841700c04479"
