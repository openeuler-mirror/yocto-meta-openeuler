PV = "0.18"

SRC_URI:prepend = "file://${BP}.tar.xz \
"

# 0.18 switched from autotools to meson; the package is allarch and
# only installs index.theme, no compilation needed
do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${datadir}/icons/hicolor
    install -m 0644 ${S}/index.theme ${D}${datadir}/icons/hicolor/index.theme
    for d in 16x16/actions 16x16/apps 16x16/devices 16x16/emblems 16x16/mimetypes 16x16/places 16x16/status              22x22/actions 22x22/apps 22x22/devices 22x22/mimetypes 22x22/places 22x22/status              24x24/actions 24x24/apps 24x24/devices 24x24/mimetypes 24x24/places 24x24/status              32x32/actions 32x32/apps 32x32/devices 32x32/mimetypes 32x32/places 32x32/status              36x36/actions 36x36/apps 36x36/devices 36x36/mimetypes 36x36/places 36x36/status              48x48/actions 48x48/apps 48x48/devices 48x48/mimetypes 48x48/places 48x48/status              64x64/actions 64x64/apps 64x64/devices 64x64/mimetypes 64x64/places 64x64/status              72x72/actions 72x72/apps 72x72/devices 72x72/mimetypes 72x72/places 72x72/status              96x96/actions 96x96/apps 96x96/devices 96x96/mimetypes 96x96/places 96x96/status              128x128/actions 128x128/apps 128x128/devices 128x128/mimetypes 128x128/places 128x128/status              256x256/actions 256x256/apps 256x256/devices 256x256/mimetypes 256x256/places 256x256/status              scalable/actions scalable/apps scalable/devices scalable/mimetypes scalable/places scalable/status; do
        install -d ${D}${datadir}/icons/hicolor/$d
    done
}
