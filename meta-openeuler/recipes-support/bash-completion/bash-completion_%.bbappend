# version in openEuler
PV = "2.12.0"

LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

# add patches in openEuler
SRC_URI:prepend = " \
    file://${BP}.tar.xz \
    file://bash-completion-2.12.0-remove-python2.patch \
    file://backport-fix-feh-fix-nounset-error.patch \
    file://backport-fix-_umount-feh-sbopkg-check-diretory-name-for-_comp.patch \
    file://backpoft-fix_regression_of_unwanted_trailing_colons.patch \
    file://backport-fix-available_interfaces-strip-only-trailing-colon-f.patch \
"
