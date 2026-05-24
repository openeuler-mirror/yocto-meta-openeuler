PV = "0.0.28"

S = "${WORKDIR}/${BP}"

SRC_URI:prepend = "file://${BP}.tar.bz2 "

SRC_URI:remove = "git://pagure.io/xmlto.git;protocol=https;branch=master"

SRC_URI[sha256sum] = "1130df3a7957eb9f6f0d29e4aa1c75732a7dfb6d639be013859b5c7ec5421276"
