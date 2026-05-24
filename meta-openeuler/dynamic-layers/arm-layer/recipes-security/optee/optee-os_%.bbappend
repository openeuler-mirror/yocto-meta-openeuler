SRCPV = ""

SRC_URI = " \
    file://optee-os \
"

S = "${WORKDIR}/optee-os"

do_compile:prepend(){
}

TARGET_CFLAGS += " -Wuninitialized -Wmaybe-uninitialized "
