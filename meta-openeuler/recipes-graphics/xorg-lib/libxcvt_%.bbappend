SRC_URI:remove = "git://gitlab.freedesktop.org/xorg/lib/libxcvt.git;protocol=https;branch=master"

SRC_URI:prepend = "file://${BP}.tar.xz \
           "

S = "${WORKDIR}/${BP}"
