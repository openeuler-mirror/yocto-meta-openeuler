# main bbfile: yocto-poky/meta/recipes-devtools/perl/libxml-parser-perl_2.46.bb
PV = "2.46"

OPENEULER_LOCAL_NAME = "perl-XML-Parser"

LIC_FILES_CHKSUM = "file://Parser.pm;md5=0254be9da8ed205093b908b383dbacd4"

# openeuler source
SRC_URI:prepend = "file://XML-Parser-${PV}.tar.gz \
                  "
                  
S = "${WORKDIR}/XML-Parser-${PV}"
