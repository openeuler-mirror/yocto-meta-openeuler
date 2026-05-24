# bbfile: yocto-poky/meta/recipes-devtools/swig/swig_4.0.2.bb

PV = "4.1.1"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# use openeuler source (pcre2 patches not needed)
SRC_URI:prepend = "file://${BP}.tar.gz \
           "
