# wireless-regdb-static is regulatory.db* (need for cfg80211 database)
RDEPENDS:packagegroup-base:append = " \
e2fsprogs-resize2fs \
linux-firmware-rpidistro-compat-bcm43xx \
wireless-regdb-static \
wpa-supplicant \
dsoftbus \
bluez5 \
${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', 'kernel-module-brcmfmac-wcc' ,'', d)} \
"

