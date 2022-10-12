SUMMARY = "image base utils"
PR = "r1"

#
# packages which content depend on MACHINE_FEATURES need to be MACHINE_ARCH
#
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

# PACKAGES is "${PN}" by default
# if you want to add new groups by RDEPENDS_xx, you show add new group to PACKAGES
PACKAGES = "${PN} ${PN}-extended"

RDEPENDS_packagegroup-base = " \
acl \
attr \
bind-dhclient \
bind-dhclient-utils \
dhcp-client \
dhcp-server \
dhcp-server-config \
dhcp-omshell \
dhcp-relay \
cifs-utils \
cronie \
curl \
dosfstools \
e2fsprogs \
e2fsprogs-tune2fs \
ethtool \
expat \
grep \
gzip \
initscripts \
iproute2-ip \
iptables \
json-c \
kmod \
less \
libaio \
libasm \
libcap \
libcap-bin \
libcap-ng \
libcap-ng-bin \
libdw \
libffi \
libhugetlbfs \
libnl \
libnl-cli \
libnl-xfrm \
libpcap \
libpwquality \
libselinux-bin \
libsepol-bin \
libxml2 \
libxml2-utils \
logrotate \
lvm2 \
ncurses \
ncurses-libform \
ncurses-libmenu \
ncurses-libpanel \
ncurses-terminfo \
ncurses-terminfo-base \
pciutils \
perf \
policycoreutils \
policycoreutils-fixfiles \
policycoreutils-hll \
policycoreutils-loadpolicy \
policycoreutils-semodule \
policycoreutils-sestatus \
policycoreutils-setfiles \
procps \
pstree \
quota \
rsyslog \
sed \
shadow-base \
squashfs-tools \
tzdata-core \
util-linux-su \
util-linux-libfdisk \
xz \
nfs-utils \
nfs-utils-client \
libusb1 \
glib-2.0 \
libbfd \
expect \
"

RDEPENDS_packagegroup-base-extended = " \
sysfsutils \
libmetal \
openamp \
"

RDEPENDS_packagegroup-base_append_aarch64-std = " \
dsoftbus \
"

RDEPENDS_packagegroup-base_append_raspberrypi4-64 = " \
dsoftbus \
"

RDEPENDS_packagegroup-base_remove_riscv64 += " \
libhugetlbfs \
"

RDEPENDS_packagegroup-base-extended_remove_riscv64 += " \
libmetal \
openamp \
"
