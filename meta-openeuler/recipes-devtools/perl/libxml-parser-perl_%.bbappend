# main bbfile: yocto-poky/meta/recipes-devtools/perl/libxml-parser-perl_2.46.bb
PV = "2.46"

OPENEULER_REPO_NAME = "perl-XML-Parser"

# openeuler source
SRC_URI:prepend = "file://XML-Parser-${PV}.tar.gz \
                  "
                  
S = "${WORKDIR}/XML-Parser-${PV}"
