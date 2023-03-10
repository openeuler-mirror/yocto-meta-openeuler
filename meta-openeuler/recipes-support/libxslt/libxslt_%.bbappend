PV = "1.1.37"

SRC_URI_prepend = "file://CVE-2015-9019.patch \
"

SRC_URI[md5sum] = "43dee91d34fb76ec9e0a02a65e09c5ab"
SRC_URI[sha256sum] = "3a4f58957cd0755b0188a17393c701cbd3e7812d236db185bceee77e52906580"

EXTRA_OECONF_remove = "--with-html-subdir=${BPN}"
