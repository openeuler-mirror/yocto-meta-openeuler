# main: yocto-poky/meta/recipes-devtools/python/python3-docutils_0.18.1.bb

PV = "0.20.1"
LIC_FILES_CHKSUM = "file://COPYING.txt;md5=08f5f8aa6a1db2500c08a2bb558e45af"
require pypi-src-openeuler.inc

# diff 0.20.1.bb ~ 0.18.1.bb
do_install:append() {
    for f in rst2html rst2html4 rst2html5 rst2latex rst2man \
	           rst2odt rst2odt_prepstyles rst2pseudoxml rst2s5 rst2xetex rst2xml \
	           rstpep2html
    do
        mv ${D}${bindir}/$f.py ${D}${bindir}/$f;
    done
}