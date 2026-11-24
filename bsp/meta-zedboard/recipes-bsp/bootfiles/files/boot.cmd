setenv bootargs console=ttyPS0,115200 net.ifnames=0 root=/dev/mmcblk0p2 rootwait rw

fatload mmc 0:1 0x00200000 zImage
fatload mmc 0:1 0x01000000 zynq-zed.dtb
bootz 0x00200000 - 0x01000000