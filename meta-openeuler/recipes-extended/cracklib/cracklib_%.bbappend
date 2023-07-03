OPENEULER_SRC_URI_REMOVE = "https git http"

PV = "2.9.8"

S = "${WORKDIR}/cracklib-${PV}"

# get new 0001-packlib.c-support-dictionary-byte-order-dependent.patch from higher poky
FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# delete lower version patch from poky
SRC_URI:remove = " \
    file://0001-Apply-patch-to-fix-CVE-2016-6318.patch \
"

# add openeuler patches
# note: cracklib-words may not use as src-openeuler, we may check later.
SRC_URI =+ " \
    file://cracklib-${PV}.tar.gz \
    file://fix-problem-of-error-message-about-simplistic-passwo.patch \
    file://backport-cracklib-2.9.6-lookup.patch \
    file://fix-error-length-about-simplistic-password.patch \
    file://fix-truncating-dict-file-without-input-data.patch \
"

# ref: http://cgit.openembedded.org/openembedded-core/tree/meta/recipes-extended/cracklib/cracklib_2.9.8.bb
# This is custom stuff from upstream's autogen.sh
do_configure:prepend() {
    mkdir -p ${S}/m4
    echo EXTRA_DIST = *.m4 > ${S}/m4/Makefile.am
    touch ${S}/ABOUT-NLS
}

SRC_URI[md5sum] = "48a0c8810ec4780b99c0a4f9931c21c6"
SRC_URI[sha256sum] = "8b6fd202f3f1d8fa395d3b7a5d821227cfd8bb4a9a584a7ae30cf62cea6287dd"
