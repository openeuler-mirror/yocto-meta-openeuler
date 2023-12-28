PV = "1.16.0"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

# delete conflict patches of openeuler and poky
# openeuler has add 0004 patch, not use it from poky
SRC_URI_remove = " \
        ${GNUPG_MIRROR}/gpgme/${BP}.tar.bz2 \
        file://0004-python-import.patch \
        "

# add patches from openeuler
SRC_URI_prepend = "\ 
        file://${BP}.tar.bz2 \
        file://0001-don-t-add-extra-libraries-for-linking.patch \
        file://gpgme-1.3.2-largefile.patch \
        file://0001-fix-stupid-ax_python_devel.patch \
        "

SRC_URI[sha256sum] = "4ed3f50ceb7be2fce2c291414256b20c9ebf4c03fddb922c88cda99c119a69f5"
