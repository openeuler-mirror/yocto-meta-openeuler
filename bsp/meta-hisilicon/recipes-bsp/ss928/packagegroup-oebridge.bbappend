XFCE_PKG_LISTS:append = " \
	${@bb.utils.contains('MACHINE', 'hieulerpi1', \
		bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
			lightdm:real \
			lightdm-gtk:real \
			usbutils:real \
			ristretto:real \
			pluma:real \
		', ' \
		', d) \
	, ' \
	', d)} \
"