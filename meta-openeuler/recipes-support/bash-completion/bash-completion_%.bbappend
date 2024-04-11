# version in openEuler
PV = "2.12.0"

LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

# add patches in openEuler
SRC_URI:prepend = " \
    file://${BP}.tar.xz \
    file://bash-completion-2.12.0-remove-python2.patch \
"
