PV = "2.4"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# version 2.2 don't need this patch
SRC_URI:remove = "file://0001-migrate-from-custom-itstool-to-builtin-msgfmt-for-cr.patch \
"

# openeuler patch (0002 replaces the in-tree 0001-Fix-build-with-
# libxml2-2.12.0-and-clang-17.patch, both fix the libxml2 2.12 build)
SRC_URI:prepend = "file://${BP}.tar.gz \
           file://0001-Remove-sub-classing-from-OO.o-mime-types.patch \
            file://0002-Fix-build-with-libxml2-2.12.0.patch \
"

# poky patch
SRC_URI:append = " \
            file://0002-Handle-build-with-older-versions-of-GCC.patch \
"

S = "${WORKDIR}/${BP}"

ASSUME_PROVIDE_PKGS = "shared-mime-info"
