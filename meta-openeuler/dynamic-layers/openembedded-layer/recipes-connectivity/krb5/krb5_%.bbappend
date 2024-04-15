# source bb: meta-oe/recipes-connectivity/krb5/krb5_1.17.2.bb

PV = "1.21.2"

LIC_FILES_CHKSUM = "file://${S}/../NOTICE;md5=32cb3a99207053d9f5c1ef177c4d6e34"

# apply openeuler source and patch
SRC_URI:prepend = "file://${BP}.tar.gz \
    file://ksu-pam-integration.patch;patchdir=${S}/.. \
    file://SELinux-integration.patch;patchdir=${S}/.. \
    file://Adjust-build-configuration.patch;patchdir=${S}/.. \
    file://netlib-and-dns.patch;patchdir=${S}/.. \
    file://fix-debuginfo-with-y.tab.c.patch;patchdir=${S}/.. \
    file://Remove-3des-support.patch;patchdir=${S}/.. \
    file://Fix-krb5_cccol_have_content-bad-pointer-free.patch;patchdir=${S}/.. \
"

SRC_URI:remove = " \
    file://0001-aclocal-Add-parameter-to-disable-keyutils-detection.patch \
    file://CVE-2021-36222.patch;striplevel=2 \
    file://CVE-2021-37750.patch;striplevel=2 \
    file://CVE-2022-42898.patch;striplevel=2 \
"

# the following configuration is for krb5-1.21.2
# ===============================================
inherit pkgconfig

SRC_URI[md5sum] = "7ac456e97c4959ebe5c836dc2f5aab2c"
SRC_URI[sha256sum] = "7d8d687d42aed350c2525cb69a4fc3aa791694da6761dccc1c42c2ee7796b5dd"

DEPENDS += "libselinux"

PACKAGECONFIG[keyutils] = "--with-keyutils,--without-keyutils,keyutils"

EXTRA_OECONF:remove = "--without-tcl"

PACKAGE_BEFORE_PN =+ "${PN}-admin-server \
                      ${PN}-gss-samples \
                      ${PN}-k5tls \
                      ${PN}-kdc \
                      ${PN}-kdc-ldap \
                      ${PN}-kpropd \
                      ${PN}-otp \
                      ${PN}-pkinit \
                      ${PN}-spake \
                      ${PN}-user \
                      libgssapi-krb5 \
                      libgssrpc \
                      libk5crypto \
                      libkadm5clnt-mit \
                      libkadm5srv-mit \
                      libkdb5 \
                      libkrad \
                      libkrb5 \
                      libkrb5support \
                      libverto \
"

PACKAGES = ""

inherit multilib_script
MULTILIB_SCRIPTS = "${PN}-dev:${bindir}/krb5-config"
