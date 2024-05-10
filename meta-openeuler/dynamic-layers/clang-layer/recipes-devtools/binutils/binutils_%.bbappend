LDFLAGS:append:toolchain-clang = "${@bb.utils.contains('DISTRO_FEATURES', 'ld-is-lld', ' -Wl,--undefined-version', '', d)}"

# First, I think libtool may have some problems in cross-compile environment.
# And it seems a well-known issue.
# You can google by key words "libtool cross compile /usr/lib64"

# Second, I get errors in do_install stage like,
# ld.lld: error: .libs/archive.o is incompatible with elf64-x86-64
# binutils/ld is okay because ld treats it as a warning.

# Third, the reason why it fails is that libtool adds an option `-L/usr/lib64`.
# It causes that we search -lc -lm -lz, and so on, under /usr/lib64, which are x86-64 targets.
# But we cross-compile aarch64 target. So I add an extra search path.

# Last, I do not find a official solution on libtool now,
# and lld can not convert it to warning.
# Maybe we will have a better solution in the future.
TARGET_LDFLAGS:append:toolchain-clang = "${@bb.utils.contains('DISTRO_FEATURES', 'ld-is-lld', ' -L${RECIPE_SYSROOT}/usr/lib64', '', d)}"
