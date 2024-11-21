# source bb: yocto-meta-openeuler/meta-openeuler/recipes-dbs/postgresql/postgresql_14.11.bb
PV = "15.4"

LIC_FILES_CHKSUM = "file://COPYRIGHT;md5=c31f662bb2bfb3b4187fe9a53e0ffe7c"

DEPENDS += "tcl"

SRC_URI:prepend = " \
    file://postgresql-${PV}.tar.bz2 \
    file://postgresql-datalayout-mismatch-on-s390.patch \
    file://postgresql-logging.patch \
    file://postgresql-man.patch \
    file://postgresql-no-libecpg.patch \
    file://postgresql-pgcrypto-openssl3-tests.patch \
    file://postgresql-server-pg_config.patch \
    file://postgresql-var-run-socket.patch \
    file://rpm-pgsql.patch \
"

do_configure:prepend() {
    export PATH=$PATH:${WORKDIR}/recipe-sysroot/usr/bin
}

FILES:${PN} += " \
    ${libdir}/pgsql \
"
