require recipes-core/images/image-${MACHINE}.inc
require ${@bb.utils.contains('DISTRO_FEATURES', 'xen', 'xen-image.inc', '', d)}
