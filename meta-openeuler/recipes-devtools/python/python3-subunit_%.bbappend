PV = "1.4.0"

inherit oee-archive

# upstream source
SRC_URI:prepend = " \
            file://python-subunit-${PV}.tar.gz  \
           "

SRC_URI[sha256sum] = "042039928120fbf392e8c983d60f3d8ae1b88f90a9f8fd7188ddd9c26cad1e48"
