SUMMARY = "SELinux policy core utilities"
DESCRIPTION = "policycoreutils contains the policy core utilities that are required \
for basic operation of a SELinux system.  These utilities include \
load_policy to load policies, setfiles to label filesystems, newrole \
to switch roles, and run_init to run /etc/init.d scripts in the proper \
context."
SECTION = "base"
LICENSE = "GPLv2+"

DEPENDS += "libsepol libselinux libsemanage libcap gettext-native"
EXTRA_DEPENDS = "libcap-ng"
DEPENDS += "${@['', '${EXTRA_DEPENDS}']['${PN}' != '${BPN}-native']}"

inherit selinux
DEPENDS += "${@target_selinux(d, 'audit')}"

RDEPENDS_${BPN}-fixfiles += "\
         ${BPN}-setfiles \
"
RDEPENDS_${BPN}-genhomedircon += "\
	${BPN}-semodule \
"
RDEPENDS_${BPN}-loadpolicy += "\
        libselinux \
        libsepol \
"
RDEPENDS_${BPN}-newrole += "\
	libcap-ng \
	libselinux \
"
RDEPENDS_${BPN}-runinit += "libselinux"
RDEPENDS_${BPN}-secon += "libselinux"
RDEPENDS_${BPN}-semodule += "\
        libsepol \
        libselinux \
        libsemanage \
"
RDEPENDS_${BPN}-sestatus += "libselinux"
RDEPENDS_${BPN}-setfiles += "\
        libselinux \
        libsepol \
"
RDEPENDS_${BPN}-setsebool += "\
	libsepol \
	libselinux \
	libsemanage \
"

PACKAGES =+ "\
        ${PN}-fixfiles \
        ${PN}-genhomedircon \
	${PN}-hll \
        ${PN}-loadpolicy \
	${PN}-newrole \
	${PN}-runinit \
	${PN}-secon \
        ${PN}-semodule \
	${PN}-sestatus \
        ${PN}-setfiles \
"
FILES_${PN}-fixfiles += "${base_sbindir}/fixfiles"
FILES_${PN}-genhomedircon += "${base_sbindir}/genhomedircon"
FILES_${PN}-loadpolicy += "\
	${base_sbindir}/load_policy \
"
FILES_${PN}-newrole += "\
	${bindir}/newrole \
	${@bb.utils.contains('DISTRO_FEATURES', 'pam', '${sysconfdir}/pam.d/newrole', '', d)} \
"
FILES_${PN}-runinit += "\
	${base_sbindir}/run_init \
	${base_sbindir}/open_init_pty \
	${@bb.utils.contains('DISTRO_FEATURES', 'pam', '${sysconfdir}/pam.d/run_init', '', d)} \
"
FILES_${PN}-dbg += "${prefix}/libexec/selinux/hll/.debug"
FILES_${PN}-secon += "${bindir}/secon"
FILES_${PN}-semodule += "${base_sbindir}/semodule"
FILES_${PN}-hll += "${prefix}/libexec/selinux/hll/*"
FILES_${PN}-sestatus += "\
	${base_sbindir}/sestatus \
	${sysconfdir}/sestatus.conf \
"
FILES_${PN}-setfiles += "\
	${base_sbindir}/restorecon \
	${base_sbindir}/restorecon_xattr \
	${base_sbindir}/setfiles \
"
FILES_${PN}-setsebool += "\
	${base_sbindir}/setsebool \
	${datadir}/bash-completion/completions/setsebool \
"

export STAGING_INCDIR
export STAGING_LIBDIR

AUDITH="`ls ${STAGING_INCDIR}/libaudit.h >/dev/null 2>&1 && echo /usr/include/libaudit.h `"
EXTRA_OEMAKE += "${@target_selinux(d, 'AUDITH=${AUDITH}', 'AUDITH= ')} INOTIFYH=n"
EXTRA_OEMAKE += "PREFIX=${D}"
EXTRA_OEMAKE += "INITDIR=${D}/etc/init.d"

BBCLASSEXTEND = "native"

PCU_NATIVE_CMDS = "setfiles semodule hll"

do_compile_virtclass-native() {
        for PCU_CMD in ${PCU_NATIVE_CMDS} ; do
                oe_runmake -C $PCU_CMD \
                        INCLUDEDIR='${STAGING_INCDIR}' \
                        LIBDIR='${STAGING_LIBDIR}'
       done
}

do_compile_class-native() {
	for PCU_CMD in ${PCU_NATIVE_CMDS} ; do
		oe_runmake -C $PCU_CMD \
			INCLUDEDIR='${STAGING_INCDIR}' \
			LIBDIR='${STAGING_LIBDIR}'
	done
}

do_compile_prepend() {
        export PYTHON=${PYTHON}
        export PYLIBVER='python${PYTHON_BASEVERSION}'
        export PYTHON_CPPFLAGS="-I${STAGING_INCDIR_NATIVE}/${PYLIBVER}"
        export PYTHON_LDFLAGS="${STAGING_INCDIR_NATIVE}/lib${PYLIBVER}.so"
        export PYTHON_SITE_PKG="${libdir}/${PYLIBVER}/site-packages"
}

do_install_prepend() {
        export PYTHON=${PYTHON}
        export SBINDIR="${base_sbindir}"
        export SEMODULE_PATH="${base_sbindir}" SYSTEMDDIR=${systemd_unitdir}
}

do_install_virtclass-native() {
       for PCU_CMD in ${PCU_NATIVE_CMDS} ; do
              oe_runmake -C $PCU_CMD install \
                        DESTDIR="${D}" \
                        PREFIX="${prefix}" \
                        SBINDIR="${base_sbindir}"
       done
}

do_install_class-native() {
        for PCU_CMD in ${PCU_NATIVE_CMDS} ; do
              oe_runmake -C $PCU_CMD install \
                        DESTDIR="${D}" \
                        PREFIX="${prefix}" \
                        SBINDIR="${base_sbindir}"
        done
}

do_install_append_class-target() {
        if [ -e ${WORKDIR}/pam.d ]; then
                install -d ${D}${sysconfdir}/pam.d/
                install -m 0644 ${WORKDIR}/pam.d/* ${D}${sysconfdir}/pam.d/
        fi

        # /var/lib/selinux is involved by seobject.py:
        #   + dirname = "/var/lib/selinux"
        # and it's required for running command:
        #   $ semanage permissive [OPTS]
        install -d ${D}${localstatedir}/lib/selinux
        rm -rf ${D}/lib/
  rm -r ${D}/usr/share/bash-completion
  rm -rf ${D}/usr/lib64/
  rm -rf ${D}/usr/lib/
}
