PV = "0.65.0"
#export CONFIG_SHELL="/bin/bash"

# fix rpm install error, depends to /bin/bash
RDEPENDS_${PN} += "busybox"

SRC_URI = " \
        https://github.com/rpm-software-management/libdnf/archive/${PV}/${BPN}-${PV}.tar.gz                     \
        file://add-unittest-for-setting-up-repo-with-empty-keyfile.patch \
        file://gracefully-handle-failure-to-open-repo-primary-file.patch \
        file://Fix-listing-a-repository-without-cpeid.patch \
"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += " \
           file://0001-FindGtkDoc.cmake-drop-the-requirement-for-GTKDOC_SCA.patch \
           file://0004-Set-libsolv-variables-with-pkg-config-cmake-s-own-mo.patch \
           file://0001-Get-parameters-for-both-libsolv-and-libsolvext-libdn.patch \
           file://0001-Add-WITH_TESTS-option.patch \
           file://0001-Look-fo-sphinx-only-if-documentation-is-actually-ena.patch \
           file://enable_test_data_dir_set.patch \
           file://0001-drop-FindPythonInstDir.cmake.patch \
           file://0001-libdnf-dnf-context.cpp-do-not-try-to-access-BDB-data.patch \
           "



SRC_URI[sha256sum] = "b615a6f7e1d1d82c928d2c79b36242a29d04cd28e267a5e8a6996435d9f97997"

S = "${WORKDIR}/${BP}"

# delete depends to prelink from gobject-introspection.bbclass
DEPENDS_remove_class-target = " prelink-native"
