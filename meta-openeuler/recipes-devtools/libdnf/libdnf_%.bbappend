PV = "0.69.0"
# export CONFIG_SHELL="/bin/bash"

# fix rpm install error, depends to /bin/bash
RDEPENDS:${PN}:append:class-target = " busybox"

# add new patches from openeuler
SRC_URI:prepend = " \
        file://${BP}.tar.gz                     \
        file://backport-query-py-ensure-reldep-is-from-the-same-sack.patch \
        file://0001-libdnf-0.65.0-add-loongarch-support.patch \
"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"


SRC_URI[sha256sum] = "b615a6f7e1d1d82c928d2c79b36242a29d04cd28e267a5e8a6996435d9f97997"

S = "${WORKDIR}/${BP}"
