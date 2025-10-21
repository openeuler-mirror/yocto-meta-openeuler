# main bbfile: yocto-poky/meta/recipes-devtools/perl/libxml-parser-perl_2.46.bb
PV = "2.46"

OPENEULER_LOCAL_NAME = "perl-XML-Parser"

# openeuler source
SRC_URI:prepend = "file://XML-Parser-${PV}.tar.gz \
                  "
                  
S = "${WORKDIR}/XML-Parser-${PV}"

do_configure:aarch64:append() {
    # -m64 is for x86 architecture, remove it for aarch64
    sed -i 's/-m64//g' ${S}/Expat/Makefile
}
