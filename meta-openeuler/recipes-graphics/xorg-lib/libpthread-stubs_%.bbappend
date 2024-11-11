# openeuler PV
PV = "0.4"

inherit oee-archive

# upstream source
SRC_URI:prepend = " \
            file://${BP}.tar.bz2  \
           "
