PV = "5.2"

OPENEULER_LOCAL_NAME = "tftp"

SRC_URI:prepend = "file://tftp-hpa-${PV}.tar.bz2 \
        file://tftp-doc.patch \
        file://tftp-enhanced-logging.patch \
        file://tftp-hpa-5.2-gcc10.patch \
        file://backport-Update-manpage-to-match-source-code-for-map-file.patch \
"

SRC_URI:remove = "file://0001-tftp-Mark-toplevel-definition-as-external.patch"
