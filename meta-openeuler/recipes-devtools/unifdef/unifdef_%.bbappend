PV = "2.12"

inherit oee-archive

# upstream source
SRC_URI:prepend = " \
            file://${BP}.tar.xz  \
            "

# from version 2.12, compare the differences in upstream recipe
SRC_URI[sha256sum] = "43ce0f02ecdcdc723b2475575563ddb192e988c886d368260bc0a63aee3ac400"
