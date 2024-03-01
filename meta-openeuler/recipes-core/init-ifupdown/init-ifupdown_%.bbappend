RDEPENDS:${PN} = "os-base"
RCONFLICTS:${PN} = ""

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}/:"

do_install:append() {
    # Change the static IP address of eth0 to use by default
    sed -i 's/iface eth0 inet dhcp/iface eth0 inet static\n\taddress 192.168.10.8\n\tnetmask 255.255.255.0\n\tnetwork 192.168.10.0\n\tgateway 192.168.10.1\n/g' ${D}${sysconfdir}/network/interfaces
}
