# Upstream recipe: yocto-poky/meta/recipes-extended/lzip/lzip_1.23.bb
# Source: https://atomgit.com/src-openeuler/lzip (1.26)
# 1.26 matches the OE-Core master recipe exactly: the tarball sha256 and
# both LIC sections (COPYING, decoder.cc lines 3-16) are byte-identical
PV = "1.26"

# 1.26 license texts changed from the 1.23 era; values verified against
# the OE-Core master lzip_1.26.bb recipe
LIC_FILES_CHKSUM = "file://COPYING;md5=cca7f74ec83b7a9ce7ccd195aad471bd \
                    file://decoder.cc;beginline=3;endline=16;md5=18c279060cd0be128188404b45837f88 \
"

SRC_URI:prepend = " \
    file://${BP}.tar.gz \
"

SRC_URI[sha256sum] = "641cf30961525cbe3b340cc883436c8854e9f5032f459f444de4782b621e6572"
