# main bbfile: yocto-poky/meta/recipes-devtools/perl/perl_5.32.1.bb
# add perlcross-native dependency according to http://cgit.openembedded.org/openembedded-core/tree/meta/recipes-devtools/perl/perl_5.34.0.bb?h=honister
PV = "5.34.0"

#patches from openeuler
#perl-5.34.0-Destroy-GDBM-NDBM-ODBM-SDBM-_File-objects-only-from-.patch fail
SRC_URI_prepend =+ " \
    file://perl-5.34.0.tar.xz \
    file://perl-5.22.1-Provide-ExtUtils-MM-methods-as-standalone-ExtUtils-M.patch \
    file://perl-5.16.3-create_libperl_soname.patch \
    file://perl-5.22.0-Install-libperl.so-to-shrpdir-on-Linux.patch \
    file://perl-5.35.1-Fix-GDBM_File-to-compile-with-version-1.20-and-earli.patch \
    file://perl-5.35.1-Raise-version-number-in-ext-GDBM_File-GDBM_File.pm.patch \
    file://change-lib-to-lib64.patch \
    file://disable-rpath-by-default.patch \
    file://backport-CVE-2021-36770.patch \
"

SRC_URI_remove += "https://www.cpan.org/src/5.0/perl-${PV}.tar.gz;name=perl \
           https://github.com/arsv/perl-cross/releases/download/1.3.5/perl-cross-1.3.5.tar.gz;name=perl-cross \
           file://0001-configure_tool.sh-do-not-quote-the-argument-to-comma.patch \
           file://0001-perl-cross-add-LDFLAGS-when-linking-libperl.patch \
           file://0001-configure_path.sh-do-not-hardcode-prefix-lib-as-libr.patch \
           file://determinism.patch  \
"
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
