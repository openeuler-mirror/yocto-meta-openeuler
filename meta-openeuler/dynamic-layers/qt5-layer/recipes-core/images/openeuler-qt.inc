# enable relocate SDK
SDK_RELOCATE_AFTER_INSTALL = "1"

# install qtbase to image
IMAGE_INSTALL += " \
packagegroup-qt \
"

# generate qt.conf for qmake
inherit populate_sdk_qt5_base

# install qt dev tools to SDK
TOOLCHAIN_HOST_TASK:append = " nativesdk-packagegroup-qt5-toolchain-host"
