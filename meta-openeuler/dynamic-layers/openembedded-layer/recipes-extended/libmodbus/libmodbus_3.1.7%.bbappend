# yocto-meta-openembedded/meta-oe/recipes-graphics/gphoto2/libmodbus_3.1.7.bb

# note: the upstream bb file has two version: 3.1.7 and 3.0.6, so in order to fix 
# us openeuler version better, the bbappend name set to "libmodbus_3.1%.bbappend"

PV = "3.1.6"

SRC_URI:append = " \
    file://${BP}.tar.gz \
    file://0000-libmodbus-Heap-based-Buffer-Overflow-in-modbus_reply.patch"

SRC_URI[md5sum] = "15c84c1f7fb49502b3efaaa668cfd25e"
SRC_URI[sha256sum] = "d7d9fa94a16edb094e5fdf5d87ae17a0dc3f3e3d687fead81835d9572cf87c16"
