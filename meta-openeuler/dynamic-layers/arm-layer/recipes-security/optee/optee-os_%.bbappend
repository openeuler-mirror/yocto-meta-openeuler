SRCPV = ""

SRC_URI = " \
    file://optee-os \
"

S = "${WORKDIR}/optee-os"

do_compile:prepend(){
    export PYTHONPATH=${PYTHONPATH}:${OPENEULER_NATIVESDK_SYSROOT}/usr/lib/python${PYTHON_BASEVERSION}/site-packages
}

TARGET_CFLAGS += " -Wuninitialized -Wmaybe-uninitialized "
