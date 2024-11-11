PV = "0.6.2"

inherit oee-archive

# from version 0.6.2, compare the differences in upstream recipe
SRC_URI[sha256sum] = "ac6894d876e45878faae493b0cf61d0e28ec417334448ac0a6ea2229d8343051"

# upstream source
SRC_URI:prepend = " \
            file://async-${PV}.tar.gz  \
           "
