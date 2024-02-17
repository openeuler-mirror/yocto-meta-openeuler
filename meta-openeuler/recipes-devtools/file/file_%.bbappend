PV = "5.44"

S = "${WORKDIR}/${BP}"

SRC_URI = " \
        file://${BP}.tar.gz \
        file://0001-file-localmagic.patch \
"
SRC_URI[sha256sum] = "3751c7fba8dbc831cb8d7cc8aff21035459b8ce5155ef8b0880a27d028475f3b"
