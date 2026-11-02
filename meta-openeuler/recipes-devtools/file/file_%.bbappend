PV = "5.45"

S = "${WORKDIR}/${BP}"

SRC_URI = " \
        file://${BP}.tar.gz \
        file://0001-file-localmagic.patch \
        file://0002-Prevent-incorrect-result-for-nbytes-2GB-which-needs-.patch \
"
SRC_URI[sha256sum] = "fc97f51029bb0e2c9f4e3bffefdaf678f0e039ee872b9de5c002a6d09c784d82"

ASSUME_PROVIDE_PKGS = "file-libs file"
