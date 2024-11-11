# openeuler PV
PV = "1.0.8"

inherit oee-archive

# upstream source
SRC_URI:prepend = " \
            file://gptfdisk-${PV}.tar.gz  \
           "
