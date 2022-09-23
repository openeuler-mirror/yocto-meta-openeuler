PV = "2.9.7"

# get new 0001-packlib.c-support-dictionary-byte-order-dependent.patch from higher poky
FILESEXTRAPATHS_prepend := "${THISDIR}/files/:"

# delete lower version patch from poky
SRC_URI_remove += " \
    file://0001-Apply-patch-to-fix-CVE-2016-6318.patch \
"

# add openeuler patches
SRC_URI =+ " \
           file://fix-problem-of-error-message-about-simplistic-passwo.patch \
           file://backport-cracklib-2.9.6-lookup.patch \
           file://fix-error-length-about-simplistic-password.patch \
           file://fix-truncating-dict-file-without-input-data.patch \
"

SRC_URI[md5sum] = "48a0c8810ec4780b99c0a4f9931c21c6"
SRC_URI[sha256sum] = "8b6fd202f3f1d8fa395d3b7a5d821227cfd8bb4a9a584a7ae30cf62cea6287dd"
