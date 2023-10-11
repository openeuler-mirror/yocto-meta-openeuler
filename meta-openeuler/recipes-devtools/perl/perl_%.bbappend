# main bbfile: meta-openeuler/recipes-devtools/perl/perl_5.38.0.bb

OPENEULER_SRC_URI_REMOVE = "http git"

PV = "5.38.0"

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
