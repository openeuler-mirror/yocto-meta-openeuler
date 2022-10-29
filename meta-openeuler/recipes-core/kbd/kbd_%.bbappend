# main bb file: yocto-poky/meta/recipes-core/kbd/kbd_2.4.0.bb

# use patches from src-openEuler
SRC_URI_prepend = "file://kbd-1.15-keycodes-man.patch \
                   file://kbd-1.15-sparc.patch \
                   file://kbd-1.15-unicode_start.patch \
                   file://kbd-1.15.3-dumpkeys-man.patch \
                   file://kbd-1.15.5-sg-decimal-separator.patch \
                   file://kbd-1.15.5-loadkeys-search-path.patch \
                   file://kbd-2.0.2-unicode-start-font.patch \
                   file://kbd-2.0.4-covscan-fixes.patch \
                   "
