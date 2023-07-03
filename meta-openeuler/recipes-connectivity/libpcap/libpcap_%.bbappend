# main bb file: yocto-poky/meta/recipes-connectivity/libpcap/libpcap_1.10.1.bb

# version in openEuler
PV = "1.10.3"

SRC_URI:remove = " \
https://www.tcpdump.org/release/${BP}.tar.gz \
"

SRC_URI:prepend = " \
    file://libpcap-${PV}.tar.gz \
    file://0003-pcap-linux-apparently-ctc-interfaces-on-s390-has-eth.patch \
    file://pcap-config-mitigate-multilib-conflict.patch \
"

SRC_URI[md5sum] = "c42fde2eb75a5075f19116f8c9768573"
SRC_URI[sha256sum] = "2a8885c403516cf7b0933ed4b14d6caa30e02052489ebd414dc75ac52e7559e6"
