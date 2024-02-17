
# version in openEuler
PV = "2.10"

# apply source package in openeuler
SRC_URI:prepend = "file://wpa_supplicant-${PV}.tar.gz \
           file://wpa_supplicant-gui-qt4.patch \
           "
