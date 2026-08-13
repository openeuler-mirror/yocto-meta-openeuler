
SRC_URI:prepend = " file://${BP}.tar.xz "

# qemu-system in the SDK runs inside the build container, which has no
# graphical environment, so drop the SDL backend to avoid pulling in the
# nativesdk X11 stack (libsdl2, libx11, libxcb, ...)
PACKAGECONFIG:remove:class-nativesdk = "sdl"
