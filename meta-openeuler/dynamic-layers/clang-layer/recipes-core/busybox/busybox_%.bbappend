FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# fix segmentfault error when compiling with clang
SRC_URI:append = " \
        file://0001-Make-const-ptr-assign-as-function-call-in-clang.patch \
"

# fix segmentfault error in raspberrypi
SRC_URI:append:raspberrypi4-64 = " \
        file://0001-apply-const-trick-to-ptr_to_globals.patch \
"

CFLAGS:append:raspberrypi4-64 = " -DBB_GLOBAL_CONST='' "
