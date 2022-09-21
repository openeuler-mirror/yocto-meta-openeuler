# do init_resize.sh to expand file system to use all the space on the card at first boot
CMDLINE += "${@oe.utils.conditional("AUTO-EXPAND-FS", "1", "init=/usr/lib/init_resize.sh", "", d)}"
