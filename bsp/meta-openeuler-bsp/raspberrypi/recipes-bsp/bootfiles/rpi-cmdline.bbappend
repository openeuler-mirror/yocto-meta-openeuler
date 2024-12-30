# the kernel mounts readonly rootfs by default
# the rootfs will be remounted to rw rootfs through /etc/inittab when using busybox-init start
# add rw to CMALINE when using systemd start as a workaround
CMDLINE += "rw"

# we use only one serial uart
CMDLINE += "8250.nr_uarts=1"

# do init_resize.sh to expand file system to use all the space on the card at first boot
CMDLINE += "${@oe.utils.conditional("AUTO-EXPAND-FS", "1", "init=/usr/lib/init_resize.sh", "", d)}"
