OPENEULER_REPO_NAME = "glibc"

PV = "2.38"

# source code and patches that come from openeuler
SRC_URI:prepend = "file://glibc-${PV}.tar.xz \
    file://locale-delete-no-hard-link-to-avoid-all_language-pac.patch \
"

S = "${WORKDIR}/${BP}"
