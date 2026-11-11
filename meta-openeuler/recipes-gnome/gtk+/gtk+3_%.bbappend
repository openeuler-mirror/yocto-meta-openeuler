
PV = "3.24.52"

# native build: skip the gio-querymodules tool lookup in post-install
# (poky writes the bare command name into the gio-2.0 pc file, which
# meson rejects as a tool variable)
SRC_URI += "file://skip-gio-querymodules-postinstall.patch"

# openeuler src (the repo stores the tarball without the "+": gtk-3.24.52)
SRC_URI:prepend = "file://gtk-${PV}.tar.xz \
           "

S = "${WORKDIR}/gtk-${PV}"

# no adwaita-icon-theme-symbolic to avoid the build of gtk+3-native
GTKBASE_RRECOMMENDS = "liberation-fonts \
                        gdk-pixbuf-loader-png \
                        gdk-pixbuf-loader-jpeg \
                        gdk-pixbuf-loader-gif \
                        gdk-pixbuf-loader-xpm \
                        shared-mime-info \
                        "
