SUMMARY = "SELinux binary policy manipulation library"
DESCRIPTION = "libsemanage provides an API for the manipulation of SELinux binary policies. \
It is used by checkpolicy (the policy compiler) and similar tools, as well \
as by programs like load_policy that need to perform specific transformations \
on binary policies such as customizing policy boolean settings."
SECTION = "base"
LICENSE = "LGPL-2.1-or-later"
LIC_FILES_CHKSUM = "file://${S}/COPYING;md5=a6f89e2100d9b6cdffcea4f398e37343"

require selinux_common.inc

inherit lib_package python3native

SRC_URI += "file://libsemanage-Fix-execve-segfaults-on-Ubuntu.patch \
            file://libsemanage-allow-to-disable-audit-support.patch \
            file://libsemanage-disable-expand-check-on-policy-load.patch \
           "

DEPENDS += "libsepol libselinux bzip2 python3 bison-native flex-native swig-native"
DEPENDS:append:class-target = " audit"

S = "${WORKDIR}/git/libsemanage"

PACKAGES =+ "${PN}-python"

# For /usr/libexec/selinux/semanage_migrate_store
RDEPENDS:${PN}-python += "python3-core"

FILES:${PN}-python = "${libdir}/python${PYTHON_BASEVERSION}/site-packages/* \
                      ${libexecdir}/selinux/semanage_migrate_store"
FILES:${PN}-dbg += "${libdir}/python${PYTHON_BASEVERSION}/site-packages/.debug/*"
FILES:${PN} += "${libexecdir}"

EXTRA_OEMAKE:class-native += "DISABLE_AUDIT=y"

do_compile:append() {
    oe_runmake pywrap \
        PYLIBVER='python${PYTHON_BASEVERSION}${PYTHON_ABI}' \
        PYINC='-I${STAGING_INCDIR}/${PYLIBVER}' \
        PYLIBS='-L${STAGING_LIBDIR}/${PYLIBVER} -l${PYLIBVER}'
}

do_install:append() {
    oe_runmake install-pywrap \
        PYCEXT='.so' \
        PYLIBVER='python${PYTHON_BASEVERSION}${PYTHON_ABI}' \
        PYTHONLIBDIR='${D}${libdir}/python${PYTHON_BASEVERSION}/site-packages'

    # Update "policy-version" for semanage.conf
    sed -i 's/^#\s*\(policy-version\s*=\).*$/\1 33/' \
        ${D}/etc/selinux/semanage.conf
}

BBCLASSEXTEND = "native"
