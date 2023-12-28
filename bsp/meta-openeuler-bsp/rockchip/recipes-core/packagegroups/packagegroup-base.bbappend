# add wifi related packages
RDEPENDS_packagegroup-base_append = " \
e2fsprogs-resize2fs \
rkwifibt \
wireless-regdb \
wpa-supplicant \
"

# no need of ethercat
RDEPENDS_packagegroup-base-utils_remove_rockchip = " \
ethercat \
"
