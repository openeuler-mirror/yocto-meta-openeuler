PV = "4.9"

# get extra config files from openeuler
FILESEXTRAPATHS_append := "${THISDIR}/files/:"

# apply source code and patches in openeuler
SRC_URI = "file://${BP}.tar.xz \
           ${@bb.utils.contains('PACKAGECONFIG', 'pam', '${PAM_SRC_URI}', '', d)} \
           file://shadow-4.8-goodname.patch \
           file://shadow-4.9-null-tm.patch \
           file://shadow-4.8-long-entry.patch \
           file://usermod-unlock.patch \
           file://useradd-create-directories-after-the-SELinux-user.patch \
           file://shadow-4.1.5.1-var-lock.patch \
           file://shadow-utils-fix-lock-file-residue.patch \
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
"

# add extra pam files for openeuler
PAM_SRC_URI += " \
        file://pam.d/groupmems \
        file://login.defs \
" 

# delete native patches from poky, patch failed
SRC_URI_remove_class-native += " \
           file://0001-Disable-use-of-syslog-for-sysroot.patch \
           file://0002-Allow-for-setting-password-in-clear-text.patch \
           "

SRC_URI[md5sum] = "3d97f11e66bfb0b14702b115fa8be480"
SRC_URI[sha256sum] = "3ee3081fbbcbcfea5c8916419e46bc724807bab271072104f23e7a29e9668f3a"

# no ${mandir} installed in openeuler
ALTERNATIVE_${PN}-doc = ""

# no base-passwd in openeuler
RDEPENDS_${PN}_remove += " \
                  base-passwd \
"

do_install_prepend () {
    # poky modify useradd config, need to change path
    mkdir -p ${D}${sysconfdir}/default/
    install ${S}/etc/pam.d/useradd ${D}${sysconfdir}/default/useradd
}
