
SRC_URI:prepend = " file://${BP}.tar.xz "

# qemu-native runs on the build host (container) without a
# graphical environment, explicitly drop the SDL backend
PACKAGECONFIG:remove = " sdl "
