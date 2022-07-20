# version in openEuler
PV = "8.8p1"

# apply openEuler source package
SRC_URI_remove = "http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-${PV}.tar.gz \
"

SRC_URI_prepend = "file://openssh/openssh-${PV}.tar.gz \
"

# patches in openEuler
SRC_URI += "\
file://openssh/feature-openssh-7.4-hima-sftpserver-oom-and-fix.patch \
file://openssh/backport-openssh-8.2p1-visibility.patch \
file://openssh/backport-openssh-8.0p1-keygen-strip-doseol.patch \
file://openssh/backport-openssh-7.7p1.patch \
file://openssh/backport-openssh-5.1p1-askpass-progress.patch \
file://openssh/bugfix-openssh-fix-sftpserver.patch \
file://openssh/backport-openssh-7.8p1-scp-ipv6.patch \
file://openssh/backport-openssh-6.6p1-force_krb.patch \
file://openssh/backport-openssh-8.0p1-pkcs11-uri.patch \
file://openssh/backport-fix-possible-NULL-deref-when-built-without-FIDO.patch \
file://openssh/backport-openssh-7.6p1-audit.patch \
file://openssh/backport-openssh-8.7p1-scp-kill-switch.patch \
file://openssh/backport-openssh-7.5p1-sandbox.patch \
file://openssh/backport-openssh-8.2p1-x11-without-ipv6.patch \
file://openssh/backport-openssh-7.8p1-role-mls.patch \
file://openssh/backport-openssh-4.3p2-askpass-grab-info.patch \
file://openssh/backport-openssh-7.4p1-systemd.patch \
file://openssh/backport-openssh-6.7p1-sftp-force-permission.patch \
file://openssh/backport-openssh-6.8p1-sshdT-output.patch \
file://openssh/backport-openssh-8.0p1-openssl-evp.patch \
file://openssh/backport-openssh-5.8p2-sigpipe.patch \
file://openssh/backport-openssh-8.0p1-preserve-pam-errors.patch \
file://openssh/backport-openssh-7.8p1-UsePAM-warning.patch \
file://openssh/backport-openssh-6.3p1-ctr-evp-fast.patch \
file://openssh/backport-openssh-6.4p1-fromto-remote.patch \
file://openssh/backport-openssh-7.1p2-audit-race-condition.patch \
file://openssh/bugfix-openssh-6.6p1-log-usepam-no.patch \
file://openssh/backport-openssh-6.6p1-keyperm.patch \
file://openssh/backport-openssh-7.2p2-s390-closefrom.patch \
file://openssh/backport-openssh-6.6.1p1-scp-non-existing-directory.patch \
file://openssh/backport-openssh-7.3p1-x11-max-displays.patch \
file://openssh/backport-openssh-8.0p1-openssl-kdf.patch \
file://openssh/backport-openssh-6.6p1-allow-ip-opts.patch \
file://openssh/bugfix-sftp-when-parse_user_host_path-empty-path-should-be-allowed.patch \
file://openssh/backport-openssh-5.9p1-ipv6man.patch \
"

# checksum changed
SRC_URI[sha256sum] = "4590890ea9bb9ace4f71ae331785a3a5823232435161960ed5fc86588f331fe9"

# useradd depend sysroot of /var/run, always make a default one.
do_prepare_recipe_sysroot_prepend() {
    bb.build.exec_func('do_fix_useradd_var_run', d)
}

do_fix_useradd_var_run() {
    mkdir -p ${PKG_CONFIG_SYSROOT_DIR}/var/run/
}
