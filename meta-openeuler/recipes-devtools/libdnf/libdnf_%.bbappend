PV = "0.70.2"
# export CONFIG_SHELL="/bin/bash"

# fix rpm install error, depends to /bin/bash
RDEPENDS:${PN}:append:class-target = " busybox"

# add new patches from openeuler
SRC_URI:prepend = " \
        file://${BP}.tar.gz                     \
        file://0001-libdnf-0.65.0-add-loongarch-support.patch \
        file://backport-python-bindings-Load-all-modules-with-RTLD_GLOBAL.patch \
        file://backport-Avoid-reinstalling-installonly-packages-marked-for-ERASE.patch \
        file://backport-dnf-repo-do-not-download-repository-if-our-local-cache-is-up-to-date.patch \
        file://backport-dnf-repo-Fix-utimes-error-messages.patch \
"

# remove poky conflict
SRC_URI:remove = " \
        file://0001-libdnf-dnf-context.cpp-do-not-try-to-access-BDB-data.patch \
        "

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"


SRC_URI[sha256sum] = "b615a6f7e1d1d82c928d2c79b36242a29d04cd28e267a5e8a6996435d9f97997"

S = "${WORKDIR}/${BP}"
