SUMMARY = "SELinux policy core utilities"
DESCRIPTION = "policycoreutils contains the policy core utilities that are required \
for basic operation of a SELinux system.  These utilities include \
load_policy to load policies, setfiles to label filesystems, newrole \
to switch roles, and run_init to run /etc/init.d scripts in the proper \
context."
SECTION = "base"
LICENSE = "GPL-2.0-or-later"
LIC_FILES_CHKSUM = "file://${S}/COPYING;md5=393a5ca445f6965873eca0259a17f833"

require selinux_common.inc

SRC_URI += "${@bb.utils.contains('DISTRO_FEATURES', 'pam', '${PAM_SRC_URI}', '', d)} \
            file://policycoreutils-fixfiles-de-bashify.patch \
           "

PAM_SRC_URI = "file://pam.d/newrole \
               file://pam.d/run_init \
              "

DEPENDS += "libsepol libselinux libsemanage libcap gettext-native"
EXTRA_DEPENDS = "libcap-ng libcgroup"
DEPENDS += "${@['', '${EXTRA_DEPENDS}']['${PN}' != '${BPN}-native']}"

S = "${WORKDIR}/git/policycoreutils"

inherit selinux python3native

RDEPENDS:${BPN}-fixfiles += "\
    ${BPN}-setfiles \
    grep \
    findutils \
"
RDEPENDS:${BPN}-genhomedircon += "\
    ${BPN}-semodule \
"
RDEPENDS:${BPN}-loadpolicy += "\
    libselinux \
    libsepol \
"
RDEPENDS:${BPN}-newrole += "\
    libcap-ng \
    libselinux \
"
RDEPENDS:${BPN}-runinit += "libselinux"
RDEPENDS:${BPN}-secon += "libselinux"
RDEPENDS:${BPN}-semodule += "\
    libsepol \
    libselinux \
    libsemanage \
"
RDEPENDS:${BPN}-sestatus += "libselinux"
RDEPENDS:${BPN}-setfiles += "\
    libselinux \
    libsepol \
"
RDEPENDS:${BPN}-setsebool += "\
    libsepol \
    libselinux \
    libsemanage \
"
RDEPENDS:${BPN} += "selinux-python"

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
    ${PN}-setsebool \
"
FILES:${PN}-fixfiles += "${base_sbindir}/fixfiles"
FILES:${PN}-genhomedircon += "${base_sbindir}/genhomedircon"
FILES:${PN}-loadpolicy += "\
    ${base_sbindir}/load_policy \
"
FILES:${PN}-newrole += "\
    ${bindir}/newrole \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pam', '${sysconfdir}/pam.d/newrole', '', d)} \
"
FILES:${PN}-runinit += "\
    ${base_sbindir}/run_init \
    ${base_sbindir}/open_init_pty \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pam', '${sysconfdir}/pam.d/run_init', '', d)} \
"
FILES:${PN}-dbg += "${prefix}/libexec/selinux/hll/.debug"
FILES:${PN}-secon += "${bindir}/secon"
FILES:${PN}-semodule += "${base_sbindir}/semodule"
FILES:${PN}-hll += "${prefix}/libexec/selinux/hll/*"
FILES:${PN}-sestatus += "\
    ${base_sbindir}/sestatus \
    ${sysconfdir}/sestatus.conf \
"
FILES:${PN}-setfiles += "\
    ${base_sbindir}/restorecon \
    ${base_sbindir}/restorecon_xattr \
    ${base_sbindir}/setfiles \
"
FILES:${PN}-setsebool += "\
    ${base_sbindir}/setsebool \
    ${datadir}/bash-completion/completions/setsebool \
"

export STAGING_INCDIR
export STAGING_LIBDIR
export BUILD_SYS
export HOST_SYS

PACKAGECONFIG:class-target ?= "\
        ${@bb.utils.contains('DISTRO_FEATURES', 'pam', 'libpam', '', d)} \
        audit \
"

PACKAGECONFIG[libpam] = ",,libpam,"
PACKAGECONFIG[audit] = ",,audit,"

EXTRA_OEMAKE += "\
        ${@bb.utils.contains('PACKAGECONFIG', 'libpam', 'PAMH=y', 'PAMH=', d)} \
        ${@bb.utils.contains('PACKAGECONFIG', 'audit', 'AUDITH=y', 'AUDITH=', d)} \
        INOTIFYH=n \
        PREFIX=${prefix} \
        SBINDIR=${base_sbindir} \
"

BBCLASSEXTEND = "native"

PCU_NATIVE_CMDS = "setfiles semodule hll"

do_compile:class-native() {
    for PCU_CMD in ${PCU_NATIVE_CMDS} ; do
        oe_runmake -C $PCU_CMD \
            INCLUDEDIR='${STAGING_INCDIR}' \
            LIBDIR='${STAGING_LIBDIR}'
    done
}

sysroot_stage_dirs:append:class-native() {
    cp -R $from/${prefix}/libexec $to/${prefix}/libexec
}

do_compile:prepend() {
    export PYTHON=python3
    export PYLIBVER='python${PYTHON_BASEVERSION}'
    export PYTHON_CPPFLAGS="-I${STAGING_INCDIR}/${PYLIBVER}"
    export PYTHON_LDFLAGS="${STAGING_LIBDIR}/lib${PYLIBVER}.so"
    export PYTHON_SITE_PKG="${libdir}/${PYLIBVER}/site-packages"
}

do_install:prepend() {
    export PYTHON=python3
    export SBINDIR="${D}/${base_sbindir}"
}

do_install:class-native() {
    for PCU_CMD in ${PCU_NATIVE_CMDS} ; do
        oe_runmake -C $PCU_CMD install \
            DESTDIR="${D}" \
            PREFIX="${prefix}" \
            SBINDIR="${base_sbindir}"
    done
}

do_install:append:class-target() {
    if [ -e ${WORKDIR}/pam.d ]; then
        install -d ${D}${sysconfdir}/pam.d/
        install -m 0644 ${WORKDIR}/pam.d/* ${D}${sysconfdir}/pam.d/
    fi

    # /var/lib/selinux is involved by seobject.py:
    #   + dirname = "/var/lib/selinux"
    # and it's required for running command:
    #   $ semanage permissive [OPTS]
    install -d ${D}${localstatedir}/lib/selinux
}
