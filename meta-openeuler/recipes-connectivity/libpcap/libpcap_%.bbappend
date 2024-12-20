# main bb file: yocto-poky/meta/recipes-connectivity/libpcap/libpcap_1.10.1.bb

# version in openEuler
PV = "1.10.4"

SRC_URI:prepend = " \
    file://${BP}.tar.gz \
    file://0003-pcap-linux-apparently-ctc-interfaces-on-s390-has-eth.patch \
    file://pcap-config-mitigate-multilib-conflict.patch \
    file://libpcap-Add-sw64-architecture.patch \
    file://backport-0001-CVE-2023-7256.patch \
    file://backport-0002-CVE-2023-7256.patch \
    file://backport-CVE-2024-8006.patch \
"
