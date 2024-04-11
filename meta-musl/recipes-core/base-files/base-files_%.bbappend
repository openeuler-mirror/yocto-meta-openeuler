do_install:prepend:libc-musl () {
        for d in ${dirs555}; do
                install -m 0555 -d ${D}$d
        done
        for d in ${dirs755}; do
                install -m 0755 -d ${D}$d
        done
        for d in ${dirs1777}; do
                install -m 1777 -d ${D}$d
        done
        for d in ${dirs2775}; do
                install -m 2775 -d ${D}$d
        done

        install -m 0644 ${WORKDIR}/nsswitch.conf ${D}${sysconfdir}/nsswitch.conf
}

