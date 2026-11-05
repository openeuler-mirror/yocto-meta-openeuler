# version in openEuler
PV = "1.47"

# drop the "-unknown" beta suffix autogen.sh appends outside a git
# repo; it leaks into gpg-error.pc ("1.47-unknown") and breaks the
# version checks of gnupg and friends (as OE-Core master does)
require recipes-support/gnupg/drop-unknown-suffix.inc

# stage gpgrt-config for target consumers (gnupg 2.4's configure
# prefers it over the legacy gpg-error-config, which binconfig-disabled
# replaces with an error stub); target ${bindir} is not on the PATH of
# dependent recipes, so install it as a cross script
SYSROOT_PREPROCESS_FUNCS:append = " libgpg_error_sysroot_preprocess"
libgpg_error_sysroot_preprocess() {
    install -d ${SYSROOT_DESTDIR}${bindir_crossscripts}
    install -m 0755 ${D}${bindir}/gpgrt-config ${SYSROOT_DESTDIR}${bindir_crossscripts}/gpgrt-config
}

# License update
LIC_FILES_CHKSUM:remove = "file://src/gpg-error.h.in;beginline=2;endline=18;md5=d82591bc81561f617da71e00ff4a9d79"
LIC_FILES_CHKSUM:append = " file://src/gpg-error.h.in;beginline=2;endline=18;md5=20f4cf5d81ea2fad18f6297500018654"

# patch directory
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

# apply source package in openEuler
SRC_URI:remove = "file://pkgconfig.patch "

SRC_URI:prepend = "file://${BP}.tar.gz \
        file://libgpg-error-1.29-multilib.patch \
"

ASSUME_PROVIDE_PKGS = "libgpg-error"
