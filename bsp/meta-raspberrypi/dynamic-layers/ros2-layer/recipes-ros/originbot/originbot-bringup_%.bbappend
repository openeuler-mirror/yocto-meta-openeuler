# we use ttyUSB0 as ydlidar serial port in rpi4 as default
do_configure:prepend:class-target() {
    sed -i 's:dev\/ydlidar:dev\/ttyUSB0:g' ${S}/param/ydlidar.yaml
}
