SUMMARY = "network packagegroup"
PR = "r1"

inherit packagegroup

PACKAGES = "${PN} packagegroup-network-nfs packagegroup-network-dhcp"

RDEPENDS_${PN} = " \
packagegroup-network-nfs \
packagegroup-network-dhcp \
"

RDEPENDS_${PN}-nfs = " \
nfs-utils \
nfs-utils-client \
"

RDEPENDS_${PN}-dhcp = " \
bind-dhclient \
bind-dhclient-utils \
dhcp-client \
dhcp-server \
dhcp-server-config \
dhcp-omshell \
dhcp-relay \
"

RDEPENDS_${PN}-wifi = " \
wpa-supplicant \
"

RDEPENDS_${PN}-bluetooth = " \
bluez5 \
"
