PV = "1.15"

SRC_URI:prepend = "file://${BP}.tar.gz \
           file://backport-0001-Document-the-MIT-SHM-extension.patch \
           "

SRC_URI[sha256sum] = "0e434af76af722ef9b2dc21066da1cd11e5dd85fc1996d66228d090f9ae9b217"
