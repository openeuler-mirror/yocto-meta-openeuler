# main bbfile: yocto-poky/meta/recipes-extended/shadow/shadow_4.11.bb

PV = "4.14.3"
LIC_FILES_CHKSUM = "file://COPYING;md5=c9a450b7be84eac23e6353efecb60b5b"
# get extra config files from openeuler(pam.d directory)
FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# outdated patch
SRC_URI:remove = " \
           file://shadow-4.1.3-dots-in-usernames.patch \
           file://shadow-relaxed-usernames.patch \
           "

# delete native patches from poky, patch failed, as it's for 4.11
SRC_URI:remove:class-native = " \
        file://0001-Drop-nsswitch.conf-message-when-not-in-place-eg.-musl.patch \
        file://0001-Disable-use-of-syslog-for-sysroot.patch \
        "

# use openeuler patches
SRC_URI:prepend = "file://${BP}.tar.xz \
            file://usermod-unlock.patch \
            file://shadow-add-sm3-crypt-support.patch \
            file://shadow-Remove-encrypted-passwd-for-useradd-gr.patch \
           "
# remove patches with the same functionality in src-openeuler from poky:
# file://shadow-update-pam-conf.patch
SRC_URI:remove = " \
    file://CVE-2023-29383.patch \
    file://0001-Overhaul-valid_field.patch \
"

inherit pkgconfig

# add extra pam files for openeuler
# poky shadow.inc have added: chfn chpasswd chsh login newusers passwd su
PAM_SRC_URI += " \
        file://pam.d/groupmems \
        file://login.defs \
"

SRC_URI[sha256sum] = "6969279236fe3152768573a38c9f83cb9ca109851a5a990aec1fc672ac2cfcd2"

CFLAGS:append:libc-musl = " -DLIBBSD_OVERLAY"

# no ${mandir} installed in openeuler
ALTERNATIVE:${PN}-doc = ""

do_install:append:class-target () {
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


SYSROOT_DIRS:append:class-native = " ${STAGING_DIR_NATIVE}/lib-shadow-deps/"
INSANE_SKIP:${PN}:class-native = "already-stripped"

PACKAGECONFIG[libbsd] = "--with-libbsd,--without-libbsd,libbsd"
PACKAGECONFIG[logind] = "--enable-logind,--disable-logind,systemd"

SYSROOT_DIRS:append:class-native = " ${STAGING_DIR_NATIVE}/lib-shadow-deps/"
INSANE_SKIP:${PN}:class-native = "already-stripped"

# keep as 4.13 recipe
PAM_PLUGINS:remove = "pam-plugin-lastlog"
