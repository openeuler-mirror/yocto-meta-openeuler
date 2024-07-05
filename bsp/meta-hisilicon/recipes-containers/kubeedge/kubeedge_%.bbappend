# since in hieulerpi1's kernel, we previously add the crc32c module
# into the kernel image, we do not need to add it to the rootfs
# as a seperate module.
RDEPENDS:edgecore:remove = " \
    kernel-module-libcrc32c \
"