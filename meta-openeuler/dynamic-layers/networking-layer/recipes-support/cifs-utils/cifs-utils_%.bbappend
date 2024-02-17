PV = "7.0"

SRC_URI:prepend = "file://${BP}.tar.bz2 \
           "

SRC_URI:remove = " \
                file://CVE-2022-27239.patch \
                file://CVE-2022-29869.patch \
"

SRC_URI[sha256sum] = "a7b6940e93250c1676a6fa66b6ead91b78cd43a5fee99cc462459c8b9cf1e6f4"

S = "${WORKDIR}/${BP}"

# keep the same as before, otherwise a large number of dependencies will be introduced
DEPENDS:remove = "libtalloc"
