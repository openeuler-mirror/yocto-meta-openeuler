# the main bb file: yocto-poky/meta/recipes-support/libxslt/libxslt_1.1.35.bb

PV = "1.1.37"

SRC_URI = " \
    file://${BP}.tar.gz \
"

SRC_URI[md5sum] = "43dee91d34fb76ec9e0a02a65e09c5ab"
SRC_URI[sha256sum] = "3a4f58957cd0755b0188a17393c701cbd3e7812d236db185bceee77e52906580"

EXTRA_OECONF:remove = "--with-html-subdir=${BPN}"
