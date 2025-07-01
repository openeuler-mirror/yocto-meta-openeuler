# dhcpcd bbappend to disable udev when using busybox-mdev
#
# When VIRTUAL-RUNTIME_dev_manager
# is set to busybox-mdev, udev integration is disabled to avoid unnecessary udev
# dependencies. 
# udev is integrated into system. Therefore, only if dev_manager is busybox-mdev, 
# should we remove the udev options
PACKAGECONFIG:remove = "\
    ${@bb.utils.contains('INIT_MANAGER', 'mdev-busybox', 'udev', '', d)}\
    ${@bb.utils.contains('INIT_MANAGER', 'none', 'udev', '', d)}\
"
