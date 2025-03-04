SUMMARY = "image base utils"
PR = "r1"

#
# packages which content depend on MACHINE_FEATURES need to be MACHINE_ARCH
#
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

# PACKAGES is "${PN}" by default
# if you want to add new groups by RDEPENDS:xx, you show add new group to PACKAGES
# split packagegroup-base to packagegroup-base-utils and packagegroup-base-libs
# packagegroup-base-utils means which package contains binary file for user using.
# packagegroup-base-libs means which package contains library and conf files only.
PACKAGES = "${PN} ${PN}-utils ${PN}-libs"

RDEPENDS:packagegroup-base-utils = " \
acl \
attr \
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
bzip2 \
iproute2-ip \
iptables \
kexec-tools \
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
quota \
rsyslog \
sed \
shadow-base \
squashfs-tools \
tzdata-core \
util-linux-su \
util-linux-libfdisk \
xz \
expect \
sysfsutils \
elfutils \
openssl-bin \
"

# riscv64 arch is not support kexec-tools, view yocto-poky/meta/recipes-kernel/kexec/kexec-tools_2.0.23.bb
# and check COMPATIBLE_HOST param
RDEPENDS:packagegroup-base-utils:remove:riscv64 = "\
    kexec-tools \
"


RDEPENDS:packagegroup-base-libs = " \
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
"

RDEPENDS:packagegroup-base = " \
packagegroup-base-utils \
packagegroup-base-libs \
packagegroup-entropy-daemon \
"

# for x86-64 arch, add some industrial protocol packages
RDEPENDS:packagegroup-base-utils:append:x86-64 = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', '', 'ethercat-igh', d)} \
    intel-cmt-cat \
    linuxptp \
"
