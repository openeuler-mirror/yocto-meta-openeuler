PACKAGECONFIG_append_rockchip = " hls \
                   ${@bb.utils.contains('LICENSE_FLAGS_ACCEPTED', 'commercial', 'gpl faad', '', d)}"
PACKAGECONFIG_remove = "rsvg"