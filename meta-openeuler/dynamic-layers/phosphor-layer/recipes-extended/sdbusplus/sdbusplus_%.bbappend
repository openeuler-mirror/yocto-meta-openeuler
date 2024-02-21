# we fetch the source code through openeuler_fetch.
# Thus, there are some common configurations needed to be changed.
include sdbusplus-src.inc

# the source code path to the workdir is different since we use openeuler_fetch.
S = "${WORKDIR}/${OPENEULER_LOCAL_NAME}"