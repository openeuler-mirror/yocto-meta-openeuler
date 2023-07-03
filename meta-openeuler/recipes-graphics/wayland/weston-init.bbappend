FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

# we current use rc5.d of rcS, we don't want it autostart default
# occurs when udev is used instead of systemd
INITSCRIPT_PARAMS = "start 9 2 . stop 20 0 1 6 ."
