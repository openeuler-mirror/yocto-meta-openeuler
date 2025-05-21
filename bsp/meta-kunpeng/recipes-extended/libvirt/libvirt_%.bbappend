PACKAGECONFIG = "gnutls qemu yajl openvz vbox esx test remote \
                   libvirtd netcf udev python fuse firewalld libpcap \
                   ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', 'selinux audit libcap-ng', '', d)} \
                   ${@bb.utils.contains('DISTRO_FEATURES', 'xen', 'libxl', '', d)} \
                   ${@bb.utils.contains('DISTRO_FEATURES', 'polkit', 'polkit', '', d)} \
                  "
