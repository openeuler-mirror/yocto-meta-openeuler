# main bbfile: yocto-poky/meta/recipes-extended/xz/xz_5.2.5.bb

OPENEULER_SRC_URI_REMOVE = "https git http"

LIC_FILES_CHKSUM = "file://COPYING;md5=c8ea84ebe7b93cce676b54355dc6b2c0 \
                    file://COPYING.GPLv2;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
                    file://COPYING.GPLv3;md5=1ebbd3e34237af26da5dc08a4e440464 \
                    file://COPYING.LGPLv2.1;md5=4fbd65380cdd255951079008b364516c \
                    file://lib/getopt.c;endline=23;md5=2069b0ee710572c03bb3114e4532cd84 \
                    "

# Use the source packages from openEuler
SRC_URI:remove = " \
        "

PV = "5.4.4"

SRC_URI += "file://xz-${PV}.tar.xz \
            "
#xz-native cannot dependes to xz-native
python() {
    all_depends = d.getVarFlag("do_unpack", "depends")
    for dep in ['xz']:
        all_depends = all_depends.replace('%s-native:do_populate_sysroot' % dep, "")
    new_depends = all_depends
    if d.getVar("PN") == "xz-native":
        d.setVarFlag("do_unpack", "depends", new_depends)
}
