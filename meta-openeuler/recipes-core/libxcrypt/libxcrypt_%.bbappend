
PV = "4.4.36"

# openeuler patch
SRC_URI:prepend = "file://v${PV}.tar.gz \
                file://add-sm3-crypt-support.patch \
                file://add-loongarch-support-for-libxcrypt.patch \
           "

S = "${WORKDIR}/${BP}"
