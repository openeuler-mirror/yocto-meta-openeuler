PV = "2.4"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# version 2.2 don't need this patch
SRC_URI:remove = "file://0001-migrate-from-custom-itstool-to-builtin-msgfmt-for-cr.patch \
"

# openeuler patch
SRC_URI:prepend = "file://${BP}.tar.gz \
           file://0001-Remove-sub-classing-from-OO.o-mime-types.patch \
"

S = "${WORKDIR}/${BP}"

ASSUME_PROVIDE_PKGS = "shared-mime-info"
