
PV = "3.24.41"

# openeuler src
SRC_URI:prepend = "file://gtk+-${PV}.tar.xz \
           "

# no adwaita-icon-theme-symbolic to avoid the build of gtk+3-native
GTKBASE_RRECOMMENDS = "liberation-fonts \
                        gdk-pixbuf-loader-png \
                        gdk-pixbuf-loader-jpeg \
                        gdk-pixbuf-loader-gif \
                        gdk-pixbuf-loader-xpm \
                        shared-mime-info \
                        "
