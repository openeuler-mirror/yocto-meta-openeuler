# main bbfile: yocto-poky/meta/recipes-extended/xz/xz_5.2.5.bb

OPENEULER_SRC_URI_REMOVE = "https git http"

# Use the source packages from openEuler
SRC_URI:remove = " \
        "

PV = "5.2.10"

SRC_URI += "file://xz-${PV}.tar.xz \
            "

SRC_URI[md5sum] = "1b614d27061168d13afe6221a70e173a"
SRC_URI[sha256sum] = "d615974a17299eaa1bf3d0f3b7afa172624755c8885111b17659051869d6f072"

#xz-native cannot dependes to xz-native
python() {
    all_depends = d.getVarFlag("do_unpack", "depends")
    for dep in ['xz']:
        all_depends = all_depends.replace('%s-native:do_populate_sysroot' % dep, "")
    new_depends = all_depends
    if d.getVar("PN") == "xz-native":
        d.setVarFlag("do_unpack", "depends", new_depends)
}
