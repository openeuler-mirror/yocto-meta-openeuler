require ${@bb.utils.contains('DISTRO_FEATURES', 'xen', 'xen-image.inc', '', d)}
