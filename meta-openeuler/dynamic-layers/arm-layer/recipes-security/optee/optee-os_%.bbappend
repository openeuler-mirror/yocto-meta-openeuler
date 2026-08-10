SRCPV = ""

SRC_URI = " \
    file://optee-os \
"

S = "${WORKDIR}/optee-os"

TARGET_CFLAGS += " -Wuninitialized -Wmaybe-uninitialized "
