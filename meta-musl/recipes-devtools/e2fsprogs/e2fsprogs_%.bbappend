FILESEXTRAPATHS:prepend := "${THISDIR}/e2fsprogs:"

# _syscall5() is a legacy Linux kernel macro unavailable in musl libc.
# lib/ext2fs/llseek.c uses it on non-i386 32-bit targets (e.g. ARM).
# Apply a musl-specific patch that replaces it with a direct syscall() call.
SRC_URI:append = " file://0001-musl-replace-_syscall5-with-syscall-in-llseek.patch"
