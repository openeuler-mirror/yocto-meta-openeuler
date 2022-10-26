# main bbfile: meta-networking/recipes-support/tcpdump/tcpdump_4.99.1.bb;branch=master

# version in openEuler
PV = "4.99.1"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
    http://www.tcpdump.org/release/${BP}.tar.gz \
    file://add-ptest.patch \
    file://run-ptest \
"
# files, patches that come from openeuler
SRC_URI_prepend = " \
    file://${BP}.tar.gz \
    file://backport-0002-Use-getnameinfo-instead-of-gethostbyaddr.patch \
    file://backport-0007-Introduce-nn-option.patch \
    file://backport-0009-Change-n-flag-to-nn-in-TESTonce.patch \
    file://backport-Set-SA_RESTART-non-lethal-signals-avoid-corrupting-binary-pcap-output.patch \
"
SRC_URI[md5sum] = "929a255c71a9933608bd7c31927760f7"
SRC_URI[sha256sum] = "79b36985fb2703146618d87c4acde3e068b91c553fb93f021a337f175fd10ebe"

