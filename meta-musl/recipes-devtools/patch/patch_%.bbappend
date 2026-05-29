# charset.alias is a gettext/gnulib artifact for iconv charset name mapping.
# On musl, it is installed by the gnulib module but serves no purpose and is
# not referenced by any other package.  Drop it so do_package_qa passes.
do_install:append() {
    rm -f ${D}${libdir}/charset.alias
    rmdir --ignore-fail-on-non-empty ${D}${libdir}
}
