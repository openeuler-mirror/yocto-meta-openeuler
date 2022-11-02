# main bb file: openembedded-core/recipes-support/libseccomp/libseccomp_2.5.3.bb; branch: kirkstone

SRC_URI_remove = "git://github.com/seccomp/libseccomp.git;branch=release-2.5;protocol=https \
                  "

SRC_URI_prepend = "file://${BP}.tar.gz \
                   file://backport-bpf-pfc-Add-handling-for-0-syscalls-in-the-binary-tr.patch \
                   file://backport-tests-Add-a-binary-tree-test-with-zero-syscalls.patch \
                   "

SRC_URI[md5sum] = "5096d3912a605a72b27805fa0ef9886d"
SRC_URI[sha256sum] = "59065c8733364725e9721ba48c3a99bbc52af921daf48df4b1e012fbc7b10a76"

S = "${WORKDIR}/${BP}"

REQUIRED_DISTRO_FEATURES_remove = "seccomp"

