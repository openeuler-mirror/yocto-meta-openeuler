# bbfile: yocto-poky/meta/recipes-extended/at/at_3.2.5.bb

SRC_URI = "file://at_${PV}.orig.tar.gz \
        file://at-3.2.5-address-sast.patch \
        file://at-aarch64.patch \
        file://at-3.2.5-make.patch \
        file://at-3.2.5-pam.patch \
        file://at-3.1.14-opt_V.patch \
        file://at-3.2.2-shell.patch \
        file://at-3.2.5-nitpicks.patch \
        file://at-3.1.14-fix_no_export.patch \
        file://at-3.2.5-mailwithhostname.patch \
        file://at-3.2.5-aborted-jobs.patch \
        file://at-3.2.5-noabort.patch \
        file://at-3.1.16-fclose-error.patch \
        file://at-3.1.16-clear-nonjobs.patch \
        file://at-3.2.2-lock-locks.patch \
        file://at-3.1.23-document-n.patch \
        file://at-3.1.20-log-jobs.patch \
        file://at-3.2.5-past-date.patch \
        file://atd.init \
        file://atd.service \
        file://pam_atd \
"

copy_posix_files() {
    :
}

do_configure:prepend() {
    sed -i 's/-o $(INSTALL_ROOT_USER) -g $(DAEMON_GROUPNAME) pam_atd/-g $(DAEMON_GROUPNAME) pam_atd/' ${S}/Makefile.in
}

do_install:prepend() {
    cp -f ${WORKDIR}/pam_atd ${S}/pam_atd
    install -d ${D}/var/spool/at/jobs
    install -d ${D}/var/spool/at/spool
}

ASSUME_PROVIDE_PKGS = "at"
