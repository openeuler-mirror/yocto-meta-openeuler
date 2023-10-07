# add wifi related packages
RDEPENDS:packagegroup-base:append = " \
wpa-supplicant \
wififirmware \
"

# no need of ethercat
RDEPENDS:packagegroup-base-utils:remove:rockchip = " \
ethercat \
"
