OPENEULER_REPO_NAME = "gettext"

PV = "0.22.5"

# upstream src and patches
SRC_URI:prepend = " file://gettext-${PV}.tar.gz \
           "
