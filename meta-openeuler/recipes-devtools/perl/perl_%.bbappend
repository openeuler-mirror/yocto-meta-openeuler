# main bbfile: yocto-poky/meta/recipes-devtools/perl/perl_5.32.1.bb
# add perlcross-native dependency according to http://cgit.openembedded.org/openembedded-core/tree/meta/recipes-devtools/perl/perl_5.34.0.bb?h=honister
OPENEULER_SRC_URI_REMOVE = "https"

PV = "5.34.0"


#patches from openeuler
#perl-5.34.0-Destroy-GDBM-NDBM-ODBM-SDBM-_File-objects-only-from-.patch fail
# perl-5.34.0-Link-XS-modules-to-libperl.so-with-EU-MM-on-Linux.patch result in compile faild
SRC_URI_prepend =+ "file://perl-5.34.0.tar.xz \
            file://perl-5.22.1-Provide-ExtUtils-MM-methods-as-standalone-ExtUtils-M.patch \
            file://perl-5.16.3-create_libperl_soname.patch \
            file://perl-5.22.0-Install-libperl.so-to-shrpdir-on-Linux.patch \
            file://perl-5.35.1-Fix-GDBM_File-to-compile-with-version-1.20-and-earli.patch \
            file://perl-5.35.1-Raise-version-number-in-ext-GDBM_File-GDBM_File.pm.patch \
            file://change-lib-to-lib64.patch \
            file://disable-rpath-by-default.patch \
            file://backport-CVE-2021-36770.patch \
            file://backport-CVE-2023-31484.patch \
            file://backport-CVE-2023-31486.patch \
            file://backport-CVE-2022-48522.patch \
"

SRC_URI_remove += "\
            file://0001-configure_tool.sh-do-not-quote-the-argument-to-comma.patch \
            file://0001-perl-cross-add-LDFLAGS-when-linking-libperl.patch \
            file://0001-configure_path.sh-do-not-hardcode-prefix-lib-as-libr.patch \
            file://determinism.patch \
"

SRC_URI[perl.sha256sum] = "551efc818b968b05216024fb0b727ef2ad4c100f8cb6b43fab615fa78ae5be9a"

# get cross compile script from perlcross-native, and before configure
do_configure_prepend() {
    cp -rfp ${STAGING_DATADIR_NATIVE}/perl-cross/* ${S}
}
do_copy_perlcross() {
    :
}
DEPENDS += "perlcross-native"

# Specify the sysroot when running do_configure, solving compilation problem: "No error definitions found at Errno_pm.PL"
PACKAGECONFIG_CONFARGS_class-target += "--sysroot=${STAGING_DIR_HOST}"

RDEPENDS_${PN}-module-io-file += "${PN}-module-symbol"
