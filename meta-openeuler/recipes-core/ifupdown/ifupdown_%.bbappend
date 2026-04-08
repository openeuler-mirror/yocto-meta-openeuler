# 原bb文件do_install逻辑有问题，会导致ifup.ifupdown无法被strip
do_install () {
	install -d ${D}${mandir}/man8 \
		  ${D}${mandir}/man5 \
		  ${D}${base_sbindir}

	# If volatiles are used, then we'll also need /run/network there too.
	install -d ${D}/etc/default/volatiles
	install -m 0644 ${WORKDIR}/99_network ${D}/etc/default/volatiles

	install -m 0755 ifup ${D}${base_sbindir}/
	install -m 0755 ifup ${D}${base_sbindir}/ifdown
	install -m 0644 ifup.8 ${D}${mandir}/man8
	install -m 0644 interfaces.5 ${D}${mandir}/man5
	cd ${D}${mandir}/man8 && ln -s ifup.8 ifdown.8
}

