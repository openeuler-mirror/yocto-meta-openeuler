# main bbfile: meta-networking/recipes-support/tcpdump/tcpdump_4.99.1.bb;branch=master

# version in openEuler
PV = "4.99.4"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI:remove = " \
    file://add-ptest.patch \
    file://run-ptest \
"
# files, patches that come from openeuler
# the backport-0003-Drop-root-priviledges-before-opening-first-savefile-.patch will result in error
SRC_URI:prepend = " \
    file://${BP}.tar.gz \
    file://backport-0002-Use-getnameinfo-instead-of-gethostbyaddr.patch \
    file://backport-0007-Introduce-nn-option.patch \
    file://backport-0009-Change-n-flag-to-nn-in-TESTonce.patch \
    file://tcpdump-Add-sw64-architecture.patch \
"
SRC_URI[md5sum] = "d90471c90f780901e591807927ef0f07"
SRC_URI[sha256sum] = "0232231bb2f29d6bf2426e70a08a7e0c63a0d59a9b44863b7f5e2357a6e49fea"
