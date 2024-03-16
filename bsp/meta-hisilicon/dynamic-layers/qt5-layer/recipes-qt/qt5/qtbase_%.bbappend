# not enable systemd
PACKAGECONFIG:remove = "udev libinput"

# enable linuxfb platform
PACKAGECONFIG:append = " linuxfb"
