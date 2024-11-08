OPENEULER_LOCAL_NAME = "gettext"

PV = "0.22"

# upstream src and patches
SRC_URI:prepend = " file://gettext-${PV}.tar.gz \
           "
