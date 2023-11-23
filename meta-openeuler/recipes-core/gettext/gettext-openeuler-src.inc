OPENEULER_REPO_NAME = "gettext"
OPENEULER_SRC_URI_REMOVE = "https"

PV = "0.22"

# upstream src and patches
SRC_URI:prepend = " file://gettext-${PV}.tar.gz \
           "
