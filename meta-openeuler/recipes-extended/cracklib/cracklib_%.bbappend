PV = "2.9.8"

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

SRC_URI[md5sum] = "95af362be51495fd6d5dc593e4a5e187"
SRC_URI[sha256sum] = "268733f8c5f045a08bf1be2950225efeb3d971e31eb543c002269d1a3d98652d"
