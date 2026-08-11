inherit oee-archive

SRC_URI:prepend = " \
    file://cdrtools-${PV}.tar.bz2 \
"

# cdrtools 3.01 build system runs several configure steps concurrently
# sharing the same conftest.c/config.cache, which corrupts each other
# under parallel make (-j N): sizeof checks fail, SIZEOF_* stay undefined
# and schily/stdint.h errors out. Build serially to keep configure correct.
PARALLEL_MAKE = "-j 1"
