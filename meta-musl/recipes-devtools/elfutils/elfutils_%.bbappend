# delete conflict patches from poky
SRC_URI:remove = " \
           file://0015-config-eu.am-do-not-use-Werror.patch \
"
FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"
# Fixed the gelf.h bug
SRC_URI:append = " \
        file://elfutils-gelf-musl.patch \
"

