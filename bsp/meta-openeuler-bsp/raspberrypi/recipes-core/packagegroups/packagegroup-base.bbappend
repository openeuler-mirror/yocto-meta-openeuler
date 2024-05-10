RDEPENDS:packagegroup-base:append = " \
e2fsprogs-resize2fs \
linux-firmware-rpidistro-compat-bcm43xx \
wpa-supplicant \
dsoftbus \
bluez5 \
${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', 'kernel-module-brcmfmac-wcc' ,'', d)} \
"

