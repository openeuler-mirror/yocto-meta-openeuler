# openeuler version
PV = "3.1"


inherit oee-archive

# upstream source
SRC_URI:prepend = " \
            file://libnss-nis-${PV}.tar.gz  \
           "
