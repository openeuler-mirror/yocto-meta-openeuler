SUMMARY = "A suite of security-related network utilities based on \
the SSH protocol including the ssh client and sshd server"
DESCRIPTION = "Secure rlogin/rsh/rcp/telnet replacement (OpenSSH) \
Ssh (Secure Shell) is a program for logging into a remote machine \
and for executing commands on a remote machine."
HOMEPAGE = "http://www.openssh.com/"
SECTION = "console/network"
LICENSE = "BSD & ISC & MIT"

DEPENDS = "zlib openssl"
#DEPENDS = "zlib openssl virtual/crypt"
DEPENDS += "${@bb.utils.contains('DISTRO_FEATURES', 'pam', 'libpam', '', d)}"

#inherit manpages useradd update-rc.d update-alternatives systemd

# remove base-passwd from all image
DEPENDS_remove_class-target += "base-passwd"
USERADDSETSCENEDEPS_remove_class-target += "${MLPREFIX}base-passwd:do_populate_sysroot_setscene"

USERADD_PACKAGES = "${PN}-sshd"
USERADD_PARAM_${PN}-sshd = "--system --no-create-home --home-dir /var/run/sshd --shell /bin/false --user-group sshd"
INITSCRIPT_PACKAGES = "${PN}-sshd"
INITSCRIPT_NAME_${PN}-sshd = "sshd"
INITSCRIPT_PARAMS_${PN}-sshd = "defaults 9"

SYSTEMD_PACKAGES = "${PN}-sshd"
SYSTEMD_SERVICE_${PN}-sshd = "sshd.socket"

inherit autotools-brokensep

LIC_FILES_CHKSUM="file://LICENCE;md5=d9d2753bdef9f19466dc7bc959114b11"
EXTRA_AUTORECONF_DEFINE = " ACLOCAL=echo "

PACKAGECONFIG ??= ""
PACKAGECONFIG[kerberos] = "--with-kerberos5,--without-kerberos5,krb5"
PACKAGECONFIG[ldns] = "--with-ldns,--without-ldns,ldns"
PACKAGECONFIG[libedit] = "--with-libedit,--without-libedit,libedit"
PACKAGECONFIG[manpages] = "--with-mantype=man,--with-mantype=cat"

# login path is hardcoded in sshd
EXTRA_OECONF = "'LOGIN_PROGRAM=${base_bindir}/login' \
                ${@bb.utils.contains('DISTRO_FEATURES', 'pam', '--with-pam', '--without-pam', d)} \
                --without-zlib-version-check \
                --with-privsep-path=${localstatedir}/run/sshd \
                --sysconfdir=${sysconfdir}/ssh \
                --with-xauth=${bindir}/xauth \
                --disable-strip \
                "

# musl doesn't implement wtmp/utmp
EXTRA_OECONF_append_libc-musl = " --disable-wtmp"

# Since we do not depend on libbsd, we do not want configure to use it
# just because it finds libutil.h.  But, specifying --disable-libutil
# causes compile errors, so...
CACHED_CONFIGUREVARS += "ac_cv_header_bsd_libutil_h=no ac_cv_header_libutil_h=no"

# passwd path is hardcoded in sshd
CACHED_CONFIGUREVARS += "ac_cv_path_PATH_PASSWD_PROG=${bindir}/passwd"

# We don't want to depend on libblockfile
CACHED_CONFIGUREVARS += "ac_cv_header_maillock_h=no"

# copy SRC_URI files
SRC_URI = "file://openssh/${BP}.tar.gz \
file://ssh_config \
file://init \
file://sshd.socket \
file://sshd@.service \
file://sshdgenkeys.service \
file://volatiles.99_sshd \
file://config/common/sshd_check_keys \
file://sshd_config \
file://sshd_config_readonly \
file://sshd \
"

PAM_SRC_URI = "file://sshd"
SRC_URI_EXTRA = "file://ssh_config \
           file://init \
           ${@bb.utils.contains('DISTRO_FEATURES', 'pam', '${PAM_SRC_URI}', '', d)} \
           file://sshd.socket \
           file://sshd@.service \
           file://sshdgenkeys.service \
           file://volatiles.99_sshd \
           file://config/common/sshd_check_keys \
           "

do_configure_prepend () {
        export LD="${CC}"
       install -m 0644 ${WORKDIR}/ssh_config ${B}/
}

do_install_append () {
        if [ "${@bb.utils.filter('DISTRO_FEATURES', 'pam', d)}" ]; then
#                install -D -m 0644 ${WORKDIR}/openssh-8.2p1/sshd ${D}${sysconfdir}/pam.d/sshd
                sed -i -e 's:#UsePAM no:UsePAM yes:' ${D}${sysconfdir}/ssh/sshd_config
        fi

        if [ "${@bb.utils.filter('DISTRO_FEATURES', 'x11', d)}" ]; then
                sed -i -e 's:#X11Forwarding no:X11Forwarding yes:' ${D}${sysconfdir}/ssh/sshd_config
        fi

        install -d ${D}${sysconfdir}/init.d
        install -m 0750 ${WORKDIR}/init ${D}${sysconfdir}/init.d/sshd
        rm -f ${D}${bindir}/slogin ${D}${datadir}/Ssh.bin
        rmdir ${D}${localstatedir}/run/sshd ${D}${localstatedir}/run ${D}${localstatedir}
        install -d ${D}/${sysconfdir}/default/volatiles
        install -m 644 ${WORKDIR}/volatiles.99_sshd ${D}/${sysconfdir}/default/volatiles/99_sshd
        install -m 0755 ${S}/contrib/ssh-copy-id ${D}${bindir}

        # Create config files for read-only rootfs
        install -d ${D}${sysconfdir}/ssh
        install -m 644 ${D}${sysconfdir}/ssh/sshd_config ${D}${sysconfdir}/ssh/sshd_config_readonly
        sed -i '/HostKey/d' ${D}${sysconfdir}/ssh/sshd_config_readonly
        echo "HostKey /var/run/ssh/ssh_host_rsa_key" >> ${D}${sysconfdir}/ssh/sshd_config_readonly
        echo "HostKey /var/run/ssh/ssh_host_ecdsa_key" >> ${D}${sysconfdir}/ssh/sshd_config_readonly
        echo "HostKey /var/run/ssh/ssh_host_ed25519_key" >> ${D}${sysconfdir}/ssh/sshd_config_readonly

        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/sshd.socket ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/sshd@.service ${D}${systemd_unitdir}/system
        install -c -m 0644 ${WORKDIR}/sshdgenkeys.service ${D}${systemd_unitdir}/system
        sed -i -e 's,@BASE_BINDIR@,${base_bindir},g' \
                -e 's,@SBINDIR@,${sbindir},g' \
                -e 's,@BINDIR@,${bindir},g' \
                -e 's,@LIBEXECDIR@,${libexecdir}/${BPN},g' \
                ${D}${systemd_unitdir}/system/sshd.socket ${D}${systemd_unitdir}/system/*.service

        sed -i -e 's,@LIBEXECDIR@,${libexecdir}/${BPN},g' \
                ${D}${sysconfdir}/init.d/sshd
	cp ${WORKDIR}/ssh_config ${D}${sysconfdir}/ssh/ssh_config
	cp ${WORKDIR}/sshd_config ${D}${sysconfdir}/ssh/sshd_config
	cp ${WORKDIR}/sshd_config_readonly ${D}${sysconfdir}/ssh/sshd_config_readonly
	install -d ${D}${sysconfdir}/pam.d
	cp ${WORKDIR}/sshd ${D}${sysconfdir}/pam.d/sshd

        install -D -m 0755 ${WORKDIR}/config/common/sshd_check_keys ${D}${libexecdir}/${BPN}/sshd_check_keys
	chmod -s ${D}/usr/libexec/ssh-keysign
	chmod 0600 ${D}${sysconfdir}/ssh/sshd_config
        rm -rf ${D}/lib/
}

ALLOW_EMPTY_${PN} = "0"

PACKAGES =+ "${PN}-keygen ${PN}-scp ${PN}-ssh ${PN}-sshd ${PN}-sftp ${PN}-misc ${PN}-sftp-server"
FILES_${PN}-scp = "${bindir}/scp.${BPN} ${bindir}/scp"
FILES_${PN}-ssh = "${bindir}/ssh.${BPN} ${sysconfdir}/ssh/ssh_config"
FILES_${PN}-sshd = "${sbindir}/sshd ${sysconfdir}/init.d/sshd ${systemd_unitdir}/system"
FILES_${PN}-sshd += "${sysconfdir}/ssh/moduli ${sysconfdir}/ssh/sshd_config ${sysconfdir}/ssh/sshd_config_readonly ${sysconfdir}/default/volatiles/99_sshd ${sysconfdir}/pam.d/sshd"
FILES_${PN}-sshd += "${libexecdir}/${BPN}/sshd_check_keys"
FILES_${PN}-sftp = "${bindir}/sftp"
FILES_${PN}-sftp-server = "${libexecdir}/sftp-server"
FILES_${PN}-misc = "${bindir}/ssh* ${libexecdir}/ssh*"
FILES_${PN}-keygen = "${bindir}/ssh-keygen"

RDEPENDS_${PN} += "${PN}-scp ${PN}-ssh ${PN}-sshd ${PN}-keygen"
RDEPENDS_${PN}-sshd += "${PN}-keygen ${@bb.utils.contains('DISTRO_FEATURES', 'pam', 'pam-plugin-keyinit pam-plugin-loginuid', '', d)}"
#RRECOMMENDS_${PN}-sshd_append_class-target = " rng-tools"

RPROVIDES_${PN}-ssh = "ssh"
RPROVIDES_${PN}-sshd = "sshd"

RCONFLICTS_${PN} = "dropbear"
RCONFLICTS_${PN}-sshd = "dropbear"

CONFFILES_${PN}-sshd = "${sysconfdir}/ssh/sshd_config"
CONFFILES_${PN}-ssh = "${sysconfdir}/ssh/ssh_config"

BBCLASSEXTEND += "nativesdk"
