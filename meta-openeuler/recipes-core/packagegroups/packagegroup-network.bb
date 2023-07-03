SUMMARY = "network packagegroup"
PR = "r1"

inherit packagegroup

PACKAGES = "${PN} packagegroup-network-nfs packagegroup-network-dhcp"

RDEPENDS:${PN} = " \
packagegroup-network-nfs \
packagegroup-network-dhcp \
"

RDEPENDS:${PN}-nfs = " \
nfs-utils \
nfs-utils-client \
"

RDEPENDS:${PN}-dhcp = " \
bind-dhclient \
bind-dhclient-utils \
dhcp-client \
dhcp-server \
dhcp-server-config \
dhcp-omshell \
dhcp-relay \
"

RDEPENDS:${PN}-wifi = " \
wpa-supplicant \
"

RDEPENDS:${PN}-bluetooth = " \
bluez5 \
"
