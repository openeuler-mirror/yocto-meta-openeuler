# openeuler version
PV = "1.64"

# remove poky src_uri
OPENEULER_SRC_URI_REMOVE = "git https http"

# openeuler src
SRC_URI:prepend = "file://diffstat-${PV}.tgz \
                  "

S = "${WORKDIR}/diffstat-${PV}"
