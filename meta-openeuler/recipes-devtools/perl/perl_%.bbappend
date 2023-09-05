# main bbfile: yocto-poky/meta/recipes-devtools/perl/perl_5.34.1.bb
PV = "5.38.0"

# We remove the patches which is not suitable for openEuler
SRC_URI:remove = " \
           https://www.cpan.org/src/5.0/perl-${PV}.tar.gz;name=perl \
           file://0001-Fix-build-with-gcc-12.patch \
"


# patches from openeuler
# perl-5.34.0-Destroy-GDBM-NDBM-ODBM-SDBM-_File-objects-only-from-.patch fail:
# GDBM_File.xs:16:2: error: unknown type name 'tTHX'
SRC_URI:prepend = " file://perl-${PV}.tar.xz \
           file://perl-5.22.1-Provide-ExtUtils-MM-methods-as-standalone-ExtUtils-M.patch \
           file://perl-5.16.3-create_libperl_soname.patch \
           file://perl-5.22.0-Install-libperl.so-to-shrpdir-on-Linux.patch \
           file://change-lib-to-lib64.patch \
           file://disable-rpath-by-default.patch \
"

# Perl officially discourges the use of threads
# fix error: ld.bfd: libperl.so.5.38.0: undefined reference to `PL_curpad'
do_configure:remove = "-Dusethreads"

# Specify the sysroot when running do_configure, solving compilation problem: "No error definitions found at Errno_pm.PL"
PACKAGECONFIG_CONFARGS:class-target += "--sysroot=${STAGING_DIR_HOST}"
