# This file should be included in openeuler-image.bbappend, openeuler-image-ros.bbappend, etc.
# diff from ${MACHINE}.inc, it should not be included in live image

require recipes-core/images/bsp-${MACHINE}.inc

# all app and tools
IMAGE_INSTALL += " \
acl \
attr \
cronie \
curl \
ethtool \
expat \
grep \
gzip \
bzip2 \
iproute2-ip \
iptables \
kmod \
less \
logrotate \
lvm2 \
pciutils \
policycoreutils \
policycoreutils-fixfiles \
policycoreutils-hll \
policycoreutils-loadpolicy \
policycoreutils-semodule \
policycoreutils-sestatus \
policycoreutils-setfiles \
nlopt \
procps \
pstree \
rsyslog \
sed \
shadow-base \
tzdata-core \
util-linux-su \
util-linux-libfdisk \
xz \
expect \
initscripts \
json-c \
libcap-bin \
libcap-ng-bin \
libmodbus \
libnl-cli \
libnl-xfrm \
libpcap \
libpwquality \
libselinux-bin \
libsepol-bin \
libxml2-utils \
ncurses \
ncurses-libform \
ncurses-libmenu \
ncurses-libpanel \
ncurses-terminfo \
ncurses-terminfo-base \
libusb1 \
glib-2.0 \
libbfd \
wpa-supplicant \
hostapd \
hipico-mpp-sample \
"

# some packages to be removed from IMAGE_INSTALL
IMAGE_INSTALL:remove = " \
packagegroup-core-tools-debug \
packagegroup-network \
packagegroup-base \
"
