
PV = "2.8"

# upstream src and patches
SRC_URI:prepend = " file://${BP}.tar.gz \
                    file://0001-pigz-fix-cc.patch \
           "

SRC_URI[sha256sum] = "eb872b4f0e1f0ebe59c9f7bd8c506c4204893ba6a8492de31df416f0d5170fd0"
