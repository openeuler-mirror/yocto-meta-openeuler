PV = "0.8"

SRC_URI:prepend = "\
    file://${BPN}-${PV}.tar.gz \
    file://0000-avahi-dnsconfd.service-Drop-Also-avahi-daemon.socket.patch \
    file://0001-man-add-missing-bshell.1-symlink.patch \
    file://0002-Ship-avahi-discover-1-bssh-1-and-bvnc-1-also-for-GTK.patch \
    file://0003-fix-requires-in-pc-file.patch \
    file://0004-fix-bytestring-decoding-for-proper-display.patch \
    file://0005-avahi_dns_packet_consume_uint32-fix-potential-undefi.patch \
    file://backport-CVE-2021-3468.patch \
    file://backport-CVE-2021-36217.patch \
    file://backport-CVE-2023-1981.patch \
    file://backport-CVE-2023-38470.patch \
    file://backport-CVE-2023-38473.patch \
    file://backport-CVE-2023-38472.patch \
    file://backport-CVE-2023-38471.patch \
    file://backport-CVE-2023-38469.patch \
"

# poky conflict
SRC_URI:remove = " \
    file://handle-hup.patch \
    file://local-ping.patch \
"
