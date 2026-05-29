# On ARM musl, the meta-openeuler bbappend does LDFLAGS:append = " -lsqlite3 -levent".
# With libtool cross-compilation, native sysroot -L paths are prepended to the
# linker command and take precedence over --sysroot.  The native (x86_64)
# libsqlite3.so is therefore found first and the ARM linker rejects it with
# "file format not recognized".
#
# The configure-generated Makefile already adds -lsqlite3/-levent where needed
# via AC_SQLITE3_VERS / AC_LIBEVENT, so the LDFLAGS append is redundant.
# Remove it for ARM to restore correct cross-compilation linker search order.
LDFLAGS:remove:arm = "-lsqlite3 -levent"
