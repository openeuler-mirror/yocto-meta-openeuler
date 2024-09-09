PV = "4.2"

SRC_URI:remove = " \
        file://Use-cross-cpp-in-incdefs.patch \
"

SRC_URI:prepend = " \
        file://${BP}.tgz \
"
