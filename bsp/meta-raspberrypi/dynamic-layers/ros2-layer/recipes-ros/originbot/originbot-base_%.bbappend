# we use ttyS0 as originbot base serial port in rpi4 as default
do_configure:prepend:class-target() {
    sed -i 's:ttyS3:ttyS0:g' ${S}/launch/robot.launch.py
}
