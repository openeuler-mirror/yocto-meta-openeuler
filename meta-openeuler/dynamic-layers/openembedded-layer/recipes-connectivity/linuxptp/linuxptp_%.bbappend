PV = "3.1.1"

SRC_URI:remove = " \
        file://Use-cross-cpp-in-incdefs.patch \
"

SRC_URI:prepend = " \
        file://${BP}.tgz \
"
