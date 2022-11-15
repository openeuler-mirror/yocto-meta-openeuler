SRC_URI_remove = "https://www.cairographics.org/releases/${BP}.tar.gz \
"

SRC_URI_prepend = "file://${BPN}-${BP}.tar.bz2 \
"

S = "${WORKDIR}/${BPN}-${BP}"
