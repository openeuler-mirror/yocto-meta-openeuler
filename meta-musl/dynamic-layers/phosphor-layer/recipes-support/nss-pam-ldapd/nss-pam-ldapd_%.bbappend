FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI:append = " \
        file://nss-pam-ldapd-musl.patch \
"

RDEPENDS:${PN}:remove = "nscd"
RDEPENDS:${PN} += "musl-nscd"


