# crt*.o in libgcc-external are stripped when prepare
# recipe-sysroot. It will make obj files lose symbol
# information, causing link errors. So add this term
# to prevent the strip.
INHIBIT_SYSROOT_STRIP = "1"
INHIBIT_PACKAGE_STRIP = "1"
