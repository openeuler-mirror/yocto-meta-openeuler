PV = "0.5.1"

inherit oee-archive

# from version 0.5.1, compare the differences in upstream recipe
SRC_URI[sha256sum] = "f970995ec2bb815e2fdaf7977b26b2091e1e386f0f42eafd5ac811953dc5d445"

# upstream source
SRC_URI:prepend = " \
            file://installer-${PV}.tar.gz  \
           "
