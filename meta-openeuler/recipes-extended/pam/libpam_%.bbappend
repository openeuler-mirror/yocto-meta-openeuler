PV = "1.5.2"

# get files from pam, not libpam
OPENEULER_REPO_NAME = "pam"

# delete useless patch from old version in poky bb
SRC_URI:remove = " \
    file://0001-modules-pam_namespace-Makefile.am-correctly-install-.patch \
    file://0001-Makefile.am-support-usrmage.patch \
"

# patch from openeuler
SRC_URI += " \
           file://bugfix-pam-1.1.8-faillock-systemtime.patch \
           file://change-ndbm-to-gdbm.patch \
           file://add-sm3-crypt-support.patch \
           file://1003-Change-chinese-translation.patch \
"
SRC_URI[sha256sum] = "e4ec7131a91da44512574268f493c6d8ca105c87091691b8e9b56ca685d4f94d"

DEPENDS:remove = "flex"

# no coreutils in openeuler
RDEPENDS:${PN}-xtests:remove = " \
    coreutils \
"

PACKAGES += "${PN}-pkgconfig ${PN}-service"
FILES:${PN}-pkgconfig = "${base_libdir}/pkgconfig"
FILES:${PN}-service = "/usr/lib/systemd/system"

RDEPENDS:${PN}-runtime += " \
    libpwquality \
    ${MLPREFIX}pam-plugin-faillock-${libpam_suffix} \
    ${MLPREFIX}pam-plugin-pwhistory-${libpam_suffix} \
    "

do_install:append() {
    sed -i -e '0,/^$/s//\
# lock out any user after three unsuccessful attempts and unlock that user after 5 minutes\
auth	required			pam_faillock.so preauth audit deny=3 even_deny_root unlock_time=300\
auth	sufficient			pam_unix.so nullok try_first_pass\
auth	[default=die]			pam_faillock.so authfail audit deny=3 even_deny_root unlock_time=300/' ${D}${sysconfdir}/pam.d/common-auth

    sed -i -e '0,/^$/s//\
# locks the account in case there were more than deny consecutive failed authentications\
account required			pam_faillock.so/' ${D}${sysconfdir}/pam.d/common-account

    sed -i -e '0,/^$/s//\
# forcing strong passwords\
password	requisite			pam_pwquality.so try_first_pass minclass=3 minlen=8 lcredit=0 ucredit=0 dcredit=0 ocredit=0 reject_username gecoscheck retry=3 enforce_for_root\
# prevent users from using the last 5 passwords\
password	required			pam_pwhistory.so remember=5 use_authtok enforce_for_root/' ${D}${sysconfdir}/pam.d/common-password
}
