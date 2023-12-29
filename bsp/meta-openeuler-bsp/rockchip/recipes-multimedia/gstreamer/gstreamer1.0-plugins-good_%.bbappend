PACKAGECONFIG = " \
    ${GSTREAMER_ORC} \
    ${@bb.utils.filter('DISTRO_FEATURES', 'pulseaudio x11', d)} \
    ${@bb.utils.contains('TUNE_FEATURES', 'm64', 'asm', '', d)} \
    bz2 cairo flac gudev jpeg lame libpng mpg123 soup speex taglib v4l2 \
"
