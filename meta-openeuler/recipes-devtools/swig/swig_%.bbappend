# bbfile: yocto-poky/meta/recipes-devtools/swig/swig_4.0.2.bb

PV = "4.1.1"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# use openeuler source and patches
# yocto uses pcre not pcre2, so do not apply patches for pcre2 from openeuler
SRC_URI:prepend = "file://${BP}.tar.gz \
           "

SRC_URI[sha256sum] = "2af08aced8fcd65cdb5cc62426768914bedc735b1c250325203716f78e39ac9b"
