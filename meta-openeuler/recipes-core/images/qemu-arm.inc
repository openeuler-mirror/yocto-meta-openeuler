# image configuration for arm
require qemu.inc

# use 1024M memory: initramfs for arm32 is ~180MB uncompressed, plus kernel
# needs additional memory during decompression; 256M (default) causes OOM panic
QB_MEM = "-m 1024"

IMAGE_INSTALL:remove = "packagegroup-isulad"
