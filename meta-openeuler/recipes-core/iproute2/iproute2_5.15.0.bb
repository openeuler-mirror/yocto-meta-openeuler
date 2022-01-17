require iproute2.inc

SRC_URI = "file://iproute/${BP}.tar.xz \
           file://iproute/bugfix-iproute2-3.10.0-fix-maddr-show.patch \
           file://iproute/bugfix-iproute2-change-proc-to-ipnetnsproc-which-is-private.patch \
           "

SRC_URI[sha256sum] = "56d7dcb05b564c94cf6e4549cec2f93f2dc58085355c08dcb2a8f8249c946080"

# CFLAGS are computed in Makefile and reference CCOPTS
EXTRA_OEMAKE_append = " CCOPTS='${CFLAGS}'"
