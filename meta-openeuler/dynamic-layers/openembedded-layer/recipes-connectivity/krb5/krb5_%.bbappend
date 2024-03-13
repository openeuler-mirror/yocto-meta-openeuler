# source bb: meta-oe/recipes-connectivity/krb5/krb5_1.17.2.bb

PV = "1.20.1"

LIC_FILES_CHKSUM = "file://${S}/../NOTICE;md5=1d31018dba5a0ef195eb426a1e61f02e"

# apply openeuler source and patch
SRC_URI:prepend = "file://${BP}.tar.gz \
    file://ksu-pam-integration.patch;patchdir=${S}/.. \
    file://Adjust-build-configuration.patch;patchdir=${S}/.. \
    file://netlib-and-dns.patch;patchdir=${S}/.. \
    file://fix-debuginfo-with-y.tab.c.patch;patchdir=${S}/.. \
    file://Remove-3des-support.patch;patchdir=${S}/.. \
"

SRC_URI:remove = " \
    file://0001-aclocal-Add-parameter-to-disable-keyutils-detection.patch \
    file://CVE-2021-36222.patch;striplevel=2 \
    file://CVE-2021-37750.patch;striplevel=2 \
    file://CVE-2022-42898.patch;striplevel=2 \
"

# resolve the compile_et error temporarily
# to not use the system compile_et tool and not generate compile_et tool either
# remove the generated compile_et tool and related files
EXTRA_OECONF:remove = "--with-system-et"
do_install:append () {
    rm -rf ${D}${bindir}/compile_et
    rm -rf ${D}${datadir}/et
    rm -rf ${D}${libdir}/libcom_err*
    rm ${D}/usr/include/com_err.h
}

# the following configuration is for krb5-1.20.2
# ===============================================
inherit pkgconfig

SRC_URI[md5sum] = "7ac456e97c4959ebe5c836dc2f5aab2c"
SRC_URI[sha256sum] = "7d8d687d42aed350c2525cb69a4fc3aa791694da6761dccc1c42c2ee7796b5dd"

PACKAGECONFIG[keyutils] = "--with-keyutils,--without-keyutils,keyutils"

EXTRA_OECONF:remove = "--without-tcl"

inherit multilib_script
MULTILIB_SCRIPTS = "${PN}-dev:${bindir}/krb5-config"
