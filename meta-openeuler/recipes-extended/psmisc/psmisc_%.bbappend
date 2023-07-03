# the main bb file: yocto-poky/meta/recipes-extended/psmisc/psmisc_23.4.bb

# package and patches from openeuler
PV = "23.6"

SRC_URI = " \
    file://psmisc-${PV}.tar.xz \
"

# patches from poky
SRC_URI += " \
           file://0001-Use-UINTPTR_MAX-instead-of-__WORDSIZE.patch \
"

S = "${WORKDIR}/${BPN}-${PV}"

do_configure:prepend() {
    # cannot run po/update-potfiles in new version
    if [ ! -f ${S}/po/update-potfiles ]; then
        touch ${S}/po/update-potfiles
        chmod +x ${S}/po/update-potfiles
    fi
}

SRC_URI[md5sum] = "9cbcf82bcf3ab2aab3edef361f171bb9"
SRC_URI[sha256sum] = "2c960f2949a606653a8a05701224587f56856ab7c66b6f376a589144ce248657"
