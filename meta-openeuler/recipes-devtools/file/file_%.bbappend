PV = "5.41"

S = "${WORKDIR}/${BP}"
OPENEULER_BRANCH = "master"

SRC_URI = " \
        ftp://ftp.astron.com/pub/file/file-${PV}.tar.gz \
        file://0001-file-localmagic.patch \
        file://0002-fix-typos-fxlb.patch \
"
SRC_URI[sha256sum] = "13e532c7b364f7d57e23dfeea3147103150cb90593a57af86c10e4f6e411603f"


