# we current use rc5.d of rcS, we don't want it autostart default
# occurs when udev is used instead of systemd
INITSCRIPT_PARAMS = "start 9 2 . stop 20 0 1 6 ."

do_install:append () {
    sed -i "s|^#* *background-image=.*|background-image=/usr/share/weston/openeuler.png|" ${D}${sysconfdir}/xdg/weston/weston.ini
}