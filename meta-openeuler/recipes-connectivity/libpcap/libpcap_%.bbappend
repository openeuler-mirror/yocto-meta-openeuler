# main bb file: yocto-poky/meta/recipes-connectivity/libpcap/libpcap_1.10.0.bb

# version in openEuler
PV = "1.10.1"

SRC_URI_prepend = "file://backport-0003-pcap-linux-apparently-ctc-interfaces-on-s390-has-eth.patch \
           file://backport-pcap-config-mitigate-multilib-conflict.patch \
           "

SRC_URI[md5sum] = "28e17495004036567c2cc884b51eba45"
SRC_URI[sha256sum] = "ed285f4accaf05344f90975757b3dbfe772ba41d1c401c2648b7fa45b711bdd4"
