# Common settings for all Zephyr recipes

ZEPHYR_INHERIT_CLASSES += "zephyr cmake"
inherit ${ZEPHYR_INHERIT_CLASSES}

ZEPHYR_TOOLCHAIN_VARIANT ?= "cross-compile"
require zephyr-toolchain-${ZEPHYR_TOOLCHAIN_VARIANT}.inc

ZEPHYR_MAKE_OUTPUT = "zephyr.elf"
ZEPHYR_MAKE_BIN_OUTPUT = "zephyr.bin"
ZEPHYR_MAKE_EFI_OUTPUT = "zephyr.efi"

# default use ninja as compile backend
# "-DCMAKE_TOOLCHAIN_FILE= " is a trick to bypass toolchain file for linux application
# as zephyr is not linux application
EXTRA_OECMAKE = "\
    -DCMAKE_TOOLCHAIN_FILE= \
    -DZEPHYR_BASE=${ZEPHYR_BASE} \
    -DBOARD=${ZEPHYR_BOARD} \
    -DZEPHYR_MODULES=${ZEPHYR_MODULES} \
    -DBUILD_VERSION=${ZEPHYR_VERSION} \
    "

export ZEPHYR_BASE="${S}/zephyr-${ZEPHYR_VERSION}"

DEPENDS += "gperf-native"

# The makefiles are explicit about the flags they want, so don't unset
# them so zephyr flags actually get used.
# This is done here rather than in the task so that things still work
# in devshell.

python () {
    d.delVar('CFLAGS')
    d.delVar('CXXFLAGS')
    d.delVar('LDFLAGS')
}

OE_TERMINAL_EXPORTS += "ZEPHYR_BOARD"
OE_TERMINAL_EXPORTS += "ZEPHYR_APP_DIR"
OE_TERMINAL_EXPORTS += "ZEPHYR_BASE"

do_configure:prepend() {
    # Zephyr expects CPPFLAGS as cmake argument as and ignores env variables.
    unset CPPFLAGS
}
