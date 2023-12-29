RDEPENDS_packagegroup-base_append = " \
e2fsprogs-resize2fs \
glibc-gconv-utf-16 \
"

# no need of ethercat
RDEPENDS_packagegroup-base-utils_remove_sunxi = " \
ethercat \
"
