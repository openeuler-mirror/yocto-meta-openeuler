# main bbfile: yocto-poky/meta/recipes-devtools/perl/libxml-parser-perl_2.46.bb
PV = "2.46"

OPENEULER_REPO_NAME = "perl-XML-Parser"

#patches from openeuler
SRC_URI_prepend =+ " \
    file://XML-Parser-${PV}.tar.gz \
"

SRC_URI_remove += " \
            http://www.cpan.org/modules/by-module/XML/XML-Parser-${PV}.tar.gz \
"
