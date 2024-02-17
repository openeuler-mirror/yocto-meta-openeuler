# main bb file: yocto-poky/meta/recipes-connectivity/libpcap/libpcap_1.10.1.bb

# version in openEuler
PV = "1.10.4"

SRC_URI:prepend = " \
    file://libpcap-${PV}.tar.gz \
    file://0003-pcap-linux-apparently-ctc-interfaces-on-s390-has-eth.patch \
    file://pcap-config-mitigate-multilib-conflict.patch \
    file://libpcap-Add-sw64-architecture.patch \
"
