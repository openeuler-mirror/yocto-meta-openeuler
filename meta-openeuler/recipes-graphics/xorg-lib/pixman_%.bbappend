PV = "0.40.0"

SRC_URI_remove = "https://www.cairographics.org/releases/${BP}.tar.gz \
"

SRC_URI_prepend = "file://${BPN}-${BP}.tar.bz2 \
                   file://backport-CVE-2022-44638.patch \
"

S = "${WORKDIR}/${BPN}-${BP}"
