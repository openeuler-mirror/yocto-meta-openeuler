# main bbfile: yocto-poky/meta/recipes-extended/shadow/shadow_4.8.1.bb

PV = "4.9"

# get extra config files from openeuler
FILESEXTRAPATHS_prepend := "${THISDIR}/files/:"

SRC_URI = "file://${BP}.tar.xz \
           ${@bb.utils.contains('PACKAGECONFIG', 'pam', '${PAM_SRC_URI}', '', d)} \
           file://useradd \
           "

# use openeuler patches
SRC_URI_append = " \
           file://shadow-4.8-goodname.patch \
           file://shadow-4.9-null-tm.patch \
           file://shadow-4.8-long-entry.patch \
           file://usermod-unlock.patch \
           file://useradd-create-directories-after-the-SELinux-user.patch \
           file://Makefile-include-libeconf-dependency-in-new-idmap.patch \
           file://usermod-allow-all-group-types-with-G-option.patch \
           file://useradd-avoid-generating-an-empty-subid-range.patch \
           file://libmisc-fix-default-value-in-SHA_get_salt_rounds.patch \
           file://semanage-close-the-selabel-handle.patch \
           file://Revert-useradd.c-fix-memleaks-of-grp.patch \
           file://useradd-change-SELinux-labels-for-home-files.patch \
           file://libsubid-link-to-PAM-libraries.patch \
           file://Fix-out-of-tree-builds-with-respect-to-libsubid-incl.patch \
           file://Respect-enable-static-no-in-libsubid.patch \
           file://Fixes-the-linking-issues-when-libsubid-is-static-and.patch \
           file://pwck-fix-segfault-when-calling-fprintf.patch \
           file://newgrp-fix-segmentation-fault.patch \
           file://groupdel-fix-SIGSEGV-when-passwd-does-not-exist.patch \
           file://shadow-add-sm3-crypt-support.patch \
           file://backport-useradd-modify-check-ID-range-for-system-users.patch \
           file://backport-man-po-Makefile.in-switch-from-xml2po-to-itstool.patch \
           file://backport-Only-free-sgent-if-it-was-initialized.patch \
           file://backport-Fix-parentheses-in-configure.ac.patch \
           file://backport-Added-documentation-around-CREATE_MAIL_SPOOL.patch \
           file://backport-Handle-malformed-lines-in-hushlogins-file.patch \
           file://backport-Improve-child-error-handling.patch \
           file://backport-lib-check-NULL-before-freeing-passwd-data.patch \
           file://backport-CVE-2013-4235.patch \
           file://backport-Add-header-guards.patch \
           file://backport-Change-to-strncat.patch \
           file://backport-Handle-ERANGE-error-correctly.patch \
           file://backport-Do-not-return-garbage-in-run_parts.patch \
           file://backport-Initialize-local-variables.patch \
           file://backport-libmisc-add-check-fopen-return-value-in-read_random_.patch \
           file://backport-passwd-erase-password-copy-on-all-error-branches.patch \
           file://backport-Remove-commented-out-code-and-FIXMEs.patch \
           file://backport-Remove-redeclared-variable.patch \
           file://backport-chpasswd-add-get_salt-for-generating-salt-value.patch \
           file://backport-chpasswd-fix-function-problem-with-R-parameter.patch \
           file://backport-script-to-kill-subjects-processes-from-userdel.patch \
           file://backport-Avoid-races-in-chown_tree.patch \
           file://backport-Avoid-races-in-remove_tree.patch \
           file://backport-Require-symlink-support.patch \
           file://backport-Fail-if-regular-file-pre-exists-in-copy_tree.patch \
           file://backport-More-robust-file-content-copy-in-copy_tree.patch \
           file://backport-Address-minor-compiler-warnings.patch \
           file://backport-Avoid-races-in-copy_tree.patch \
           file://backport-useradd-check-MLS-enablement-before-setting-serange.patch \
           file://backport-libmisc-minimum-id-check-for-system-accounts.patch \
           file://backort-useradd-Fix-buffer-overflow-when-using-a-prefix.patch \
           file://backport-useradd-check-if-subid-range-exists-for-user.patch \
           file://backport-Fix-off-by-one-mistakes.patch \
           file://backport-Fix-typos-in-length-calculations.patch \
           file://backport-Correctly-handle-illegal-system-file-in-tz.patch \
           file://backport-Explicitly-override-only-newlines.patch \
           file://backport-Prevent-out-of-boundary-access.patch \
           file://backport-Added-control-character-check.patch  \
           file://backport-Overhaul-valid_field.patch \
           file://backport-Read-whole-line-in-yes_or_no.patch \
           file://backport-run_parts-for-groupadd-and-groupdel.patch \
           file://backport-commonio-free-removed-database-entries.patch \
           file://backport-semanage-disconnect-to-free-libsemanage-internals.patch \
           file://backport-process_prefix_flag-Drop-privileges.patch \
           file://backport-chsh-Verify-that-login-shell-path-is-absolute.patch \
           file://backport-Plug-econf-memory-leaks.patch \
           file://backport-def_load-avoid-NULL-deref.patch \
           file://backport-Check-if-crypt_method-null-before-dereferencing.patch \
           file://backport-usermod-fix-off-by-one-issues.patch \
           file://backport-gpasswd-1-Fix-password-leak.patch \
           file://backport-chgpasswd-fix-segfault-in-command-line-options.patch \
           file://backport-chpasswd-add-IS_CRYPT_METHOD.patch \
           file://backport-Fix-yescrypt-support.patch \
           file://backport-newgrp-fix-potential-string-injection.patch \
           file://shadow-Remove-encrypted-passwd-for-useradd-gr.patch \
           file://backport-shadow-userdel-add-the-adaptation-to-the-busybox-ps-.patch \
           file://backport-lib-btrfs-avoid-NULL-dereference.patch \
           file://backport-src-passwd.c-Switch-to-day-precision.patch \
           file://backport-src-passwd-add-overflow-check.patch  \
"

# add extra pam files for openeuler
# poky shadow.inc have added: chfn chpasswd chsh login newusers passwd su
PAM_SRC_URI += " \
        file://pam.d/groupmems \
        file://login.defs \
"

# delete native patches from poky, patch failed, as it's for 4.8.1
SRC_URI_remove_class-native = " \
           file://0001-Disable-use-of-syslog-for-sysroot.patch \
           file://0002-Allow-for-setting-password-in-clear-text.patch \
           file://commonio.c-fix-unexpected-open-failure-in-chroot-env.patch \
"

# apply 4.9 specific patches, remove these when poky's shadow upgrade to 4.9
SRC_URI_append_class-native = " \
           file://49-0001-Disable-use-of-syslog-for-sysroot.patch \
           file://49-commonio.c-fix-unexpected-open-failure-in-chroot-env.patch \
           file://login.defs \
"

SRC_URI[md5sum] = "3d97f11e66bfb0b14702b115fa8be480"
SRC_URI[sha256sum] = "3ee3081fbbcbcfea5c8916419e46bc724807bab271072104f23e7a29e9668f3a"

# no ${mandir} installed in openeuler
ALTERNATIVE_${PN}-doc = ""

do_install_prepend () {
    # we use a higher version useradd config from poky honister, these functions have applied:
    # * Disable mail creation: "CREATE_MAIL_SPOOL=no"
    # * Use users group by default: "GROUP=100"
    # see: https://git.yoctoproject.org/poky/tree/meta/recipes-extended/shadow?h=honister
    mkdir -p ${D}${sysconfdir}/default/
    install -m 0644 ${WORKDIR}/useradd ${D}${sysconfdir}/default
}

do_install_append () {
    # use login.defs from openeuler, we have applied these functions as poky:
    # * Enable CREATE_HOME by default: "CREATE_HOME     yes"
    # * Make the users mailbox in ~/ not /var/spool/mail by default on an embedded system: "MAIL_FILE  .mail"  and "#MAIL_DIR    /var/spool/mail"
    # * Disable checking emails: "#MAIL_CHECK_ENAB        yes"
    # * Comment out SU_NAME to work correctly with busybox (See Bug#5359 and Bug#7173): "#SU_NAME        su"
    # * Use proper encryption for passwords: "ENCRYPT_METHOD SHA512"
    # * other list of function that compare with poky's shadow (yocto-poky/meta/recipes-extended/shadow/files/login_defs_pam.sed) :
    #   Function                login_defs_pam.sed          openeuler
    #   FAILLOG_ENAB            comment                     comment
    #   LASTLOG_ENAB            comment                     "LASTLOG_ENAB yes"
    #   MAIL_CHECK_ENAB         comment                     comment
    #   OBSCURE_CHECKS_ENAB     comment                     comment
    #   PORTTIME_CHECKS_ENAB    comment                     comment
    #   QUOTAS_ENAB             comment                     comment
    #   MOTD_FILE               comment                     comment
    #   FTMP_FILE               comment                     comment
    #   NOLOGINS_FILE           comment                     comment
    #   ENV_HZ                  comment                     comment
    #   ENV_TZ                  comment                     comment
    #   PASS_MIN_LEN            comment                     comment
    #   SU_WHEEL_ONLY           comment                     comment
    #   CRACKLIB_DICTPATH       comment                     comment
    #   PASS_CHANGE_TRIES       comment                     comment
    #   PASS_ALWAYS_WARN        comment                     comment
    #   PASS_MAX_LEN            comment                     comment
    #   PASS_MIN_LEN            comment                     comment
    #   CHFN_AUTH               comment                     comment
    #   CHSH_AUTH               comment                     noexist
    #   ISSUE_FILE              comment                     comment
    #   LOGIN_STRING            comment                     comment
    #   ULIMIT                  comment                     comment
    #   ENVIRON_FILE            comment                     comment
    # * for other difference between poky's shadow login.defs, see diff_login_defs.txt

    install -m 0644 ${WORKDIR}/login.defs ${D}${sysconfdir}/login.defs

    # use /bin/bash as default SHELL
    sed -i 's:/bin/sh:/bin/bash:g' ${D}${sysconfdir}/default/useradd
}
