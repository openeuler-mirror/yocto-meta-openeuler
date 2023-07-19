#main bbfile: yocto-poky/meta/recipes-extended/shadow/shadow_4.8.1.bb
#ref: https://git.yoctoproject.org/poky/tree/meta/recipes-extended/shadow/shadow_4.13.bb

OPENEULER_SRC_URI_REMOVE = "https git http"

PV = "4.13"

LIC_FILES_CHKSUM = "file://COPYING;md5=c9a450b7be84eac23e6353efecb60b5b \
                    file://src/passwd.c;beginline=2;endline=30;md5=758c26751513b6795395275969dd3be1 \
                    "

# get extra config files from openeuler
FILESEXTRAPATHS_prepend := "${THISDIR}/files/:"

SRC_URI = "file://${BP}.tar.xz \
           ${@bb.utils.contains('PACKAGECONFIG', 'pam', '${PAM_SRC_URI}', '', d)} \
           file://usermod-unlock.patch \
           file://backport-useradd-check-if-subid-range-exists-for-user.patch \
           file://shadow-add-sm3-crypt-support.patch \
           file://useradd \
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

# apply 4.13 specific patches, remove these when poky's shadow upgrade to 4.13
SRC_URI_append_class-native = " \
           file://413-0001-Disable-use-of-syslog-for-sysroot.patch \
           file://413-commonio.c-fix-unexpected-open-failure-in-chroot-env.patch \
           file://login.defs \
"

SRC_URI[sha256sum] = "813057047499c7fe81108adcf0cffa3ad4ec75e19a80151f9cbaa458ff2e86cd"

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
    #  ${WORKDIR}/login.defs is in PAM_SRC_URI which is controlled by PACKAGECONFIG, 
    #  so it may not exist. Here we install it when it is there
    if [ -f "${WORKDIR}/login.defs" ]; then
        install -m 0644 ${WORKDIR}/login.defs ${D}${sysconfdir}/login.defs
    fi

    # use /bin/bash as default SHELL
    sed -i 's:/bin/sh:/bin/bash:g' ${D}${sysconfdir}/default/useradd
}
