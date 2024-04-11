# main bbfile: meta-openeuler/recipes-devtools/perl/perl_5.38.0.bb

PV = "5.38.0"

# patches from openeuler
# perl-5.38.0-Link-XS-modules-to-libperl.so-with-EU-MM.patch failed:
# aarch64-openeuler-linux-gnu/bin/ld.bfd: cannot find -lperl: No such file or directory
SRC_URI:prepend = " file://${BP}.tar.xz \
           file://perl-5.22.1-Provide-ExtUtils-MM-methods-as-standalone-ExtUtils-M.patch \
           file://perl-5.16.3-create_libperl_soname.patch \
           file://perl-5.22.0-Install-libperl.so-to-shrpdir-on-Linux.patch \
           file://perl-5.34.0-Destroy-GDBM-NDBM-ODBM-SDBM-_File-objects-only-from-.patch \
           file://change-lib-to-lib64.patch \
           file://disable-rpath-by-default.patch \
           file://backport-CVE-2023-47100-CVE-2023-47038.patch \
           file://backport-CVE-2023-47039.patch \
"
