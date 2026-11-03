# the main bb file: yocto-poky/meta/recipes-devtools/orc/orc_0.4.32.bb

PV = "0.4.44"

# 0.4.44 replaced the gtk_doc meson option with hotdoc; point the
# gtk-doc class at the new option so it does not pass -Dgtk_doc
GTKDOC_MESON_OPTION = "hotdoc"

SRC_URI = "file://${BP}.tar.xz \
"

SRC_URI[sha256sum] = "4aeb97aea2b58224029dc2b23d7d064cfa990cb4fb8c4da440bcbe9c95bc5d2d"
