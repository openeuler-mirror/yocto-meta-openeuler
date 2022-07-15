inherit gettext
require m4_src.inc

# disable patches from poky
SRC_URI_remove_class-target = " \
    file://0001-Unset-need_charset_alias-when-building-for-musl.patch \
    file://serial-tests-config.patch \
    file://0001-test-getopt-posix-fix.patch \
"
