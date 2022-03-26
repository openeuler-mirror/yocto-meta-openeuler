SUMMARY = "dsoftbus"
DESCRIPTION = "dsoftbus"
PR = "r1"
LICENSE = "CLOSED"

inherit bin_package

SRC_URI = "file://dsoftbus_output"

S = "${WORKDIR}/dsoftbus_output"

FILES_${PN}-dev = "${includedir}"
FILES_${PN} = "${libdir} ${bindir} /data/"

INSANE_SKIP_${PN} += "already-stripped"

do_install() {
    #not fail when not exist dsoftbus_output
    rm -f ${S}/.xxx
    if [ -z "$(ls -A ${S})" ]; then
        bbnote bin_package has nothing to install. 
        return 0
    fi
    install -d ${D}/data/data/
    cd ${S}
    tar --no-same-owner --exclude='./patches' --exclude='./.pc' -cpf - . \
        | tar --no-same-owner -xpf - -C ${D}
}
