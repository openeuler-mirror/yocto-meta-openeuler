PV = "1.5.3"

# get files from pam, not libpam
OPENEULER_REPO_NAME = "pam"

# remove rejected patch
SRC_URI:remove = " \
        file://0001-run-xtests.sh-check-whether-files-exist.patch \
        file://CVE-2022-28321-0002.patch \
        file://0001-pam_motd-do-not-rely-on-all-filesystems-providing-a-.patch \
"

# patch from openeuler
SRC_URI += " \
           file://bugfix-pam-1.1.8-faillock-systemtime.patch \
           file://change-ndbm-to-gdbm.patch \
           file://add-sm3-crypt-support.patch \
"
SRC_URI[sha256sum] = "7ac4b50feee004a9fa88f1dfd2d2fa738a82896763050cd773b3c54b0a818283"

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
