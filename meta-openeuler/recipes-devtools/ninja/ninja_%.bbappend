PV = "1.13.2"

SRC_URI:prepend = "file://${BP}.tar.gz \
"
SRC_URI:remove = "file://885b4efb41c039789b81f0dc0d67c1ed0faea17c.patch"

S = "${WORKDIR}/${BP}"
