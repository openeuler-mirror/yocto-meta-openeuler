
PV = "8.2.0"
SRC_URI:remove = "https://download.qemu.org/${BPN}-${PV}.tar.xz"
SRC_URI:prepend = " file://${BP}.tar.xz "
SRC_URI[sha256sum] = "bf00d2fa12010df8b0ade93371def58e632cb32a6bfdc5f5a0ff8e6a1fb1bf32"
