SUMMARY = "SELinux binary policy manipulation library"
DESCRIPTION = "libsemanage provides an API for the manipulation of SELinux binary policies. \
It is used by checkpolicy (the policy compiler) and similar tools, as well \
as by programs like load_policy that need to perform specific transformations \
on binary policies such as customizing policy boolean settings."
SECTION = "base"
LICENSE = "LGPLv2.1+"

inherit lib_package

DEPENDS += "libsepol libselinux bzip2 bison-native"
DEPENDS_append_class-target += "audit"

EXTRA_OEMAKE_class-native += "DISABLE_AUDIT=y"

do_install() {
    oe_runmake install \
            DESTDIR="${D}" \
            PREFIX="${prefix}" \
            INCLUDEDIR="${includedir}" \
            LIBDIR="${libdir}" \
            SHLIBDIR="${libdir}"
}

BBCLASSEXTEND = "native"
