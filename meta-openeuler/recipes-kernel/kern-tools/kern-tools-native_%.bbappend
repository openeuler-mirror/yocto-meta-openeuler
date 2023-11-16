# main bbfile: yocto-poky/meta/recipes-kernel/kern-tools/kern-tools-native_git.bb

OPENEULER_LOCAL_NAME = "oee_archive"

# # avoid parse filespath error after adding FILESEXTRAPATHS
PV = "0.3"

SRC_URI = "file://${OPENEULER_LOCAL_NAME}/${BPN}/yocto-kernel-tools.tar.gz"

SRC_URI[sha256sum] = "063c28a7d1c9520ccfeaf2666b244cdeb1c7a1990224d7425f88a119de5f8edd"
