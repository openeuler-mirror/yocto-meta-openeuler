
PV = "2.7"

# upstream src and patches
SRC_URI:prepend = " file://${BP}.tar.gz \
                    file://0001-pigz-fix-cc.patch \
           "

SRC_URI[sha256sum] = "d2045087dae5e9482158f1f1c0f21c7d3de6f7cdc7cc5848bdabda544e69aa58"
