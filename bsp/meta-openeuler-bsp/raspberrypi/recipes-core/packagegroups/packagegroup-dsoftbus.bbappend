# The binder module is already built-in in the Raspberry Pi kernel
RDEPENDS:packagegroup-dsoftbus:remove = " \
${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', '' ,'binder', d)} \
"