# main bbfile: yocto-poky/meta/recipes-extended/xz/xz_5.2.5.bb

OPENEULER_SRC_URI_REMOVE = "https git http"

# Use the source packages from openEuler
SRC_URI_remove = " \
        "

PV = "5.2.5"

SRC_URI += "file://xz-${PV}.tar.xz \
            file://backport-CVE-2022-1271.patch \
            "

SRC_URI[md5sum] = "aa1621ec7013a19abab52a8aff04fe5b"
SRC_URI[sha256sum] = "3e1e518ffc912f86608a8cb35e4bd41ad1aec210df2a47aaa1f95e7f5576ef56"

#xz-native cannot dependes to xz-native
python() {
    all_depends = d.getVarFlag("do_unpack", "depends")
    for dep in ['xz']:
        all_depends = all_depends.replace('%s-native:do_populate_sysroot' % dep, "")
    new_depends = all_depends
    if d.getVar("PN") == "xz-native":
        d.setVarFlag("do_unpack", "depends", new_depends)
}
