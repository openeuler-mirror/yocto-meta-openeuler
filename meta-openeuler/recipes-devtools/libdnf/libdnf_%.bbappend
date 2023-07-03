PV = "0.69.0"
#export CONFIG_SHELL="/bin/bash"

# fix rpm install error, depends to /bin/bash
RDEPENDS:${PN} += "busybox"

# add new patches from openeuler
SRC_URI = " \
        file://${BPN}-${PV}.tar.gz                     \
        file://backport-query-py-ensure-reldep-is-from-the-same-sack.patch \
        file://0001-libdnf-0.65.0-add-loongarch-support.patch \
"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += " \
           file://0001-FindGtkDoc.cmake-drop-the-requirement-for-GTKDOC_SCA.patch \
           file://0004-Set-libsolv-variables-with-pkg-config-cmake-s-own-mo.patch \
           file://0001-Get-parameters-for-both-libsolv-and-libsolvext-libdn.patch \
           file://enable_test_data_dir_set.patch \
           file://0001-drop-FindPythonInstDir.cmake.patch \
           file://0001-libdnf-dnf-context.cpp-do-not-try-to-access-BDB-data.patch \
           "



SRC_URI[sha256sum] = "b615a6f7e1d1d82c928d2c79b36242a29d04cd28e267a5e8a6996435d9f97997"

S = "${WORKDIR}/${BP}"

# delete depends to prelink from gobject-introspection.bbclass
DEPENDS:remove:class-target = " prelink-native"
