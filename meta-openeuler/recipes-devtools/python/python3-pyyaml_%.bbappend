PV = "6.0.1"
LIC_FILES_CHKSUM = "file://LICENSE;md5=6d8242660a8371add5fe547adf083079"
SRC_URI[md5sum] = "1d19c798f25e58e3e582f0f8c977dbb8"
SRC_URI[sha256sum] = "68fb519c14306fec9720a2a5b45bc9f0c8d1b9c72adf45c37baedfcd949c35a2"
SRC_URI:prepend = " \
        file://PyYAML-${PV}.tar.gz \
        file://Fix-build-Error-due-to-cython-updated.patch \
        "
S = "${WORKDIR}/PyYAML-${PV}"
