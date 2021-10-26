SUMMARY = "Tools to change and administer password and group data"
HOMEPAGE = "file://pkg-shadow.alioth.debian.org"
BUGTRACKER = "files://alioth.debian.org/tracker/?group_id=30580"
SECTION = "base/utils"
LICENSE = "BSD | Artistic-1.0"

#DEPENDS = "virtual/crypt"

UPSTREAM_CHECK_URI = "https://github.com/shadow-maint/shadow/releases"

FILESEXTRAPATHS_prepend .= "${OPEN_SRC_DIR}/shadow-utils:"

inherit autotools gettext
#inherit autotools

export CONFIG_SHELL="/bin/sh"

EXTRA_OECONF += "--without-audit \
                 --without-libcrack \
                 --without-selinux \
                 --with-group-name-max-length=24 \
                 --enable-subordinate-ids=yes \
                 ${NSCDOPT}"

do_configure_prepend() {
	#pushd ${S}
	#sh autogen.sh
	#sed -i 's/faillog/faillog2/g' configure
	#sed -i 's/faillog"/faillog2"/g' configure.ac
	#popd
}

NSCDOPT = ""
NSCDOPT_class-native = "--without-nscd"
NSCDOPT_class-nativesdk = "--without-nscd"
NSCDOPT_libc-glibc = "--with-nscd"

PAM_PLUGINS = "libpam-runtime \
               pam-plugin-faildelay \
               pam-plugin-securetty \
               pam-plugin-nologin \
               pam-plugin-env \
               pam-plugin-group \
               pam-plugin-limits \
               pam-plugin-lastlog \
               pam-plugin-motd \
               pam-plugin-mail \
               pam-plugin-shells \
               pam-plugin-rootok"

PACKAGECONFIG ??= "${@bb.utils.filter('DISTRO_FEATURES', 'pam', d)} \
                   ${@bb.utils.contains('DISTRO_FEATURES', 'xattr', 'attr', '', d)}"
PACKAGECONFIG_class-native ??= "${@bb.utils.contains('DISTRO_FEATURES', 'xattr', 'attr', '', d)}"
PACKAGECONFIG_class-nativesdk = ""
PACKAGECONFIG[pam] = "--with-libpam,--without-libpam,libpam,${PAM_PLUGINS}"
#PACKAGECONFIG[attr] = "--with-attr,--without-attr,attr"
PACKAGECONFIG[acl] = "--with-acl,--without-acl,acl"

RDEPENDS_${PN} = "shadow-securetty \
                  base-passwd "

#                  util-linux-sulogin"

# Remove base-passwd for all image
RDEPENDS_${PN}_remove += "base-passwd"
RDEPENDS_${PN}_class-native = ""
RDEPENDS_${PN}_class-nativesdk = ""

SRC_URI = "file://shadow/shadow-4.8.1.tar.xz"

LIC_FILES_CHKSUM="file://COPYING;md5=ed80ff1c2b40843cf5768e5229cf16e5"

PAM_SRC_URI = "file://pam.d"
SRC_URI_EXTRA = "file://pam.d/chfn \
               file://login_defs_pam.sed \
               file://pam.d/chpasswd \
               file://pam.d/chsh \
               file://pam.d/login \
               file://pam.d/newusers \
               file://pam.d/passwd \
               file://pam.d/su"

do_install() {
        oe_runmake DESTDIR="${D}" sbindir="${base_sbindir}" usbindir="${sbindir}" install

        # Info dir listing isn't interesting at this point so remove it if it exists.
        if [ -e "${D}${infodir}/dir" ]; then
                rm -f ${D}${infodir}/dir
        fi

        # Enable CREATE_HOME by default.
        sed -i 's/#CREATE_HOME/CREATE_HOME/g' ${D}${sysconfdir}/login.defs

        # As we are on an embedded system, ensure the users mailbox is in
        # ~/ not /var/spool/mail by default, as who knows where or how big
        # /var is. The system MDA will set this later anyway.
        sed -i 's/MAIL_DIR/#MAIL_DIR/g' ${D}${sysconfdir}/login.defs
        sed -i 's/#MAIL_FILE/MAIL_FILE/g' ${D}${sysconfdir}/login.defs

        # Disable checking emails.
        sed -i 's/MAIL_CHECK_ENAB/#MAIL_CHECK_ENAB/g' ${D}${sysconfdir}/login.defs

        # Comment out SU_NAME to work correctly with busybox
        # See Bug#5359 and Bug#7173
        sed -i 's:^SU_NAME:#SU_NAME:g' ${D}${sysconfdir}/login.defs

        # Use proper encryption for passwords
        sed -i 's/^#ENCRYPT_METHOD.*$/ENCRYPT_METHOD SHA512/' ${D}${sysconfdir}/login.defs

	# keep login.defs the same fileds & values as one in the previous init-script rpm
	sed -i 's/^CHFN_RESTRICT/#CHFN_RESTRICT/g' ${D}${sysconfdir}/login.defs
	sed -i 's/^CONSOLE/#CONSOLE/g' ${D}${sysconfdir}/login.defs
	sed -i 's/^ERASECHAR/#ERASECHAR/g' ${D}${sysconfdir}/login.defs
	sed -i 's/^FAIL_DELAY/#FAIL_DELAY/g' ${D}${sysconfdir}/login.defs
	sed -i 's/^HUSHLOGIN_FILE/#HUSHLOGIN_FILE/g' ${D}${sysconfdir}/login.defs
	sed -i 's/^KILLCHAR/#KILLCHAR/g' ${D}${sysconfdir}/login.defs
	sed -i 's/^LOGIN_RETRIES/#LOGIN_RETRIES/g' ${D}${sysconfdir}/login.defs
	sed -i 's/^MAIL_FILE/#MAIL_FILE/g' ${D}${sysconfdir}/login.defs
	sed -i 's/^SYSLOG_SG_ENAB/#SYSLOG_SG_ENAB/g' ${D}${sysconfdir}/login.defs
	sed -i 's/^SYSLOG_SU_ENAB/#SYSLOG_SU_ENAB/g' ${D}${sysconfdir}/login.defs
	sed -i 's/^SYS_GID_MAX/#SYS_GID_MAX/g' ${D}${sysconfdir}/login.defs
	sed -i 's/^SYS_UID_MAX/#SYS_UID_MAX/g' ${D}${sysconfdir}/login.defs
	sed -i 's/^TTYGROUP/#TTYGROUP/g' ${D}${sysconfdir}/login.defs
	sed -i 's/^UMASK/#UMASK/g' ${D}${sysconfdir}/login.defs
	sed -i 's#^ENV_PATH.*$#ENV_PATH PATH=/usr/local/bin:/usr/bin:/bin#' ${D}${sysconfdir}/login.defs
	sed -i 's#^ENV_SUPATH.*$#ENV_SUPATH PATH=/sbin:/usr/sbin:/usr/local/sbin:/root/bin:/usr/local/bin:/usr/bin:/bin#' ${D}${sysconfdir}/login.defs
	sed -i 's#^GID_MIN.*$#GID_MIN 500#' ${D}${sysconfdir}/login.defs
	sed -i 's#^UID_MIN.*$#UID_MIN 500#' ${D}${sysconfdir}/login.defs
	sed -i 's/^#MAIL_DIR/MAIL_DIR/g' ${D}${sysconfdir}/login.defs

        # Now we don't have a mail system. Disable mail creation for now.
        sed -i 's:/bin/bash:/bin/sh:g' ${D}${sysconfdir}/default/useradd
        sed -i '/^CREATE_MAIL_SPOOL/ s:^:#:' ${D}${sysconfdir}/default/useradd

        # Use users group by default
        sed -i 's,^GROUP=1000,GROUP=100,g' ${D}${sysconfdir}/default/useradd
}

do_install_append() {
        # Ensure that the image has as a /var/spool/mail dir so shadow can
        # put mailboxes there if the user reconfigures shadow to its
        # defaults (see sed below).
        install -m 0775 -d ${D}${localstatedir}/spool/mail
        chown root:mail ${D}${localstatedir}/spool/mail

        if [ -e ${WORKDIR}/pam.d ]; then
                install -d ${D}${sysconfdir}/pam.d/
                install -m 0644 ${WORKDIR}/pam.d/* ${D}${sysconfdir}/pam.d/
                # Remove defaults that are not used when supporting PAM.
                sed -i -f ${WORKDIR}/login_defs_pam.sed ${D}${sysconfdir}/login.defs
        fi

        install -d ${D}${sbindir} ${D}${base_sbindir} ${D}${base_bindir}

        # Move binaries to the locations we want
        rm ${D}${sbindir}/vigr
        # ln -sf vipw.${BPN} ${D}${base_sbindir}/vigr
        if [ "${sbindir}" != "${base_sbindir}" ]; then
                mv ${D}${sbindir}/vipw ${D}${base_sbindir}/vipw
                rm -f ${D}${base_sbindir}/nologin
        fi
        if [ "${bindir}" != "${base_bindir}" ]; then
                mv ${D}${bindir}/login ${D}${base_bindir}/login
                rm -f ${D}${bindir}/su
        fi

        # Handle link properly after rename, otherwise missing files would
        # lead rpm failed dependencies.
        ln -sf newgrp.${BPN} ${D}${bindir}/sg
}

PACKAGES =+ "${PN}-base"
FILES_${PN}-base = "\
        ${bindir}/sg \
        ${bindir}/newgrp.shadow \
        ${bindir}/groups.shadow \
        ${sysconfdir}/pam.d/login \
        ${sysconfdir}/pam.d/su \
        ${sysconfdir}/login.defs \
"
RDEPENDS_${PN} += "${PN}-base"

#inherit update-alternatives

ALTERNATIVE_PRIORITY = "200"

ALTERNATIVE_${PN} = "passwd chfn chsh chpasswd vipw vigr nologin login su"
ALTERNATIVE_LINK_NAME[chpasswd] = "${sbindir}/chpasswd"
ALTERNATIVE_LINK_NAME[vipw] = "${base_sbindir}/vipw"
ALTERNATIVE_LINK_NAME[vigr] = "${base_sbindir}/vigr"
ALTERNATIVE_LINK_NAME[nologin] = "${base_sbindir}/nologin"

ALTERNATIVE_${PN}-base = "newgrp groups"

PACKAGE_WRITE_DEPS += "shadow-native"
pkg_postinst_${PN}_class-target () {
        if [ "x$D" != "x" ]; then
                rootarg="--root $D"
        else
        rootarg=""
        fi

        pwconv $rootarg || exit 1
        grpconv $rootarg || exit 1
}
