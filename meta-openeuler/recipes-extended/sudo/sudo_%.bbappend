# main bb file: yocto-poky/meta/recipes-extended/sudo/sudo_1.9.6p1.bb

# openEuler version
PV = "1.9.8p2"

FILESEXTRAPATHS_prepend := "${THISDIR}/files/:"

LIC_FILES_CHKSUM = "file://doc/LICENSE;md5=b969d389e79703121cbffc9f3ea18a8b"

SRC_URI_remove = "https://www.sudo.ws/dist/sudo-${PV}.tar.gz"

SRC_URI += "\
    file://0001-lib-util-mksiglist.c-correctly-include-header-for-ou.patch \
    file://0002-lib-util-mksigname.c-correctly-include-header-for-ou.patch \
"

SRC_URI += " \
    file://sudo-${PV}.tar.gz \
    file://backport-0001-CVE-2022-37434.patch \
    file://backport-0002-CVE-2022-37434.patch \
    file://backport-CVE-2022-33070.patch \
    file://backport-Fix-CVE-2022-43995-potential-heap-overflow-for-passwords.patch \
    file://backport-Fix-incorrect-SHA384-512-digest-calculation.patch \
    file://backport-sudo_passwd_verify-zero-out-des_pass-before-returnin.patch \
    file://backport-Fix-issue-protobuf-c-499-unsigned-integer-overflow.patch \
    file://backport-Fix-regression-with-zero-length-messages-introduced-.patch \
    file://backport-Fix-typo-we-should-define-SSIZE_MAX-if-it-is-not-def.patch \
    file://backport-Fix-a-clang-analyzer-14-warning-about-a-possible-NUL.patch \
    file://backport-Fix-potential-signed-integer-overflow-on-32-bit-CPUs.patch \
    file://backport-sudo_ldap_parse_options-fix-memory-leak-of-sudoRole-.patch \
    file://backport-cvtsudoers-Prevent-sudo-from-reading-into-undefined-.patch \
    file://backport-Fix-a-potential-use-after-free-bug-with-cvtsudoers-f.patch \
    file://backport-Fix-memory-leak-of-pass-in-converse.patch \
    file://backport-sudo_passwd_cleanup-Set-auth-data-to-NULL-after-free.patch \
    file://backport-sudo_rcstr_dup-Fix-potential-NULL-pointer-deref.patch \
    file://backport-CVE-2023-22809.patch \
    file://backport-Fix-a-NOPASSWD-issue-with-a-non-existent-command-whe.patch \
    file://backport-CVE-2023-27320.patch \
    file://backport-CVE-2023-28486_CVE-2023-28487.patch \
    file://Fix-compilation-error-on-sw64-arch.patch \
    file://backport-Reinstall-the-event-handler-if-we-get-EAGAIN-from-re.patch \
    file://backport-sudoers_main-defer-setting-return-value-until-the-en.patch \
    file://backport-sudo_putenv_nodebug-require-that-the-environment-str.patch \
    file://backport-Linux-execve-2-allows-argv-or-envp-to-be-NULL.patch \
    file://backport-Fix-potential-NULL-pointer-deference-found-by-clang-.patch \
"

SRC_URI[sha256sum] = "9e3b8b8da7def43b6e60c257abe80467205670fd0f7c081de1423c414b680f2d"
