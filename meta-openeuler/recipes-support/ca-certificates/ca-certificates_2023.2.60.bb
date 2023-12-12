SUMMARY = "Common CA certificates"
DESCRIPTION = "This package contains the set of CA certificates \
chosen by the Mozilla Foundation for use with the Internet PKI."
LICENSE = "GPL-2.0-or-later & MPL-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-or-later;md5=fed54355545ffd980b814dab4a3b312c"

DEPENDS += "openssl-native"

SRC_URI = "file://ca-certificates"

S = "${WORKDIR}/ca-certificates"

do_compile_prepend () {
    rm -rf ca-certificates
    mkdir ca-certificates
    mkdir ca-certificates/certs
    mkdir ca-certificates/certs/legacy-default
    mkdir ca-certificates/certs/legacy-disable
    mkdir ca-certificates/java
}

do_compile () {
    pushd ca-certificates/certs
    pwd
    cp ${S}/certdata.txt .
    python3 ${S}/certdata2pem.py >c2p.log 2>c2p.err
    popd
    pushd ca-certificates
    (
    cat <<EOF
    # This is a bundle of X.509 certificates of public Certificate
    # Authorities.  It was generated from the Mozilla root CA list.
    # These certificates and trust/distrust attributes use the file format accepted
    # by the p11-kit-trust module.
    #
    # Source: nss/lib/ckfw/builtins/certdata.txt
    # Source: nss/lib/ckfw/builtins/nssckbi.h
    #
    # Generated from:
EOF
    cat ${S}/nssckbi.h | grep -w NSS_BUILTINS_LIBRARY_VERSION | awk '{print "# " $2 " " $3}';
    echo '#';
    ) > ca-bundle.trust.p11-kit

    touch ca-bundle.legacy.default.crt
    NUM_LEGACY_DEFAULT=`find certs/legacy-default -type f | wc -l`
    if [ $NUM_LEGACY_DEFAULT -ne 0 ]; then
        for f in certs/legacy-default/*.crt; do 
        echo "processing $f"
        tbits=`sed -n '/^# openssl-trust/{s/^.*=//;p;}' $f`
        alias=`sed -n '/^# alias=/{s/^.*=//;p;q;}' $f | sed "s/'//g" | sed 's/"//g'`
        targs=""
        if [ -n "$tbits" ]; then
            for t in $tbits; do
                targs="${targs} -addtrust $t"
            done
        fi
        if [ -n "$targs" ]; then
            echo "legacy default flags $targs for $f" >> info.trust
            openssl x509 -text -in "$f" -trustout $targs -setalias "$alias" >> ca-bundle.legacy.default.crt
        fi
        done
    fi

    touch ca-bundle.legacy.disable.crt
    NUM_LEGACY_DISABLE=`find certs/legacy-disable -type f | wc -l`
    if [ $NUM_LEGACY_DISABLE -ne 0 ]; then
        for f in certs/legacy-disable/*.crt; do 
        echo "processing $f"
        tbits=`sed -n '/^# openssl-trust/{s/^.*=//;p;}' $f`
        alias=`sed -n '/^# alias=/{s/^.*=//;p;q;}' $f | sed "s/'//g" | sed 's/"//g'`
        targs=""
        if [ -n "$tbits" ]; then
            for t in $tbits; do
                targs="${targs} -addtrust $t"
            done
        fi
        if [ -n "$targs" ]; then
            echo "legacy disable flags $targs for $f" >> info.trust
            openssl x509 -text -in "$f" -trustout $targs -setalias "$alias" >> ca-bundle.legacy.disable.crt
        fi
        done
    fi

    P11FILES=`find certs -name \*.tmp-p11-kit | wc -l`
    if [ $P11FILES -ne 0 ]; then
    for p in certs/*.tmp-p11-kit; do 
        cat "$p" >> ca-bundle.trust.p11-kit
    done
    fi
    # Append our trust fixes
    cat ${S}/trust-fixes >> ca-bundle.trust.p11-kit
    popd
}

do_install () {
    install -d -m 755 ${D}/${sysconfdir}/pki/tls/certs
    install -d -m 755 ${D}/${sysconfdir}/pki/java
    install -d -m 755 ${D}/${sysconfdir}/ssl
    install -d -m 755 ${D}/${sysconfdir}/pki/ca-trust/source
    install -d -m 755 ${D}/${sysconfdir}/pki/ca-trust/source/anchors
    install -d -m 755 ${D}/${sysconfdir}/pki/ca-trust/source/blacklist
    install -d -m 755 ${D}/${sysconfdir}/pki/ca-trust/extracted
    install -d -m 755 ${D}/${sysconfdir}/pki/ca-trust/extracted/pem
    install -d -m 755 ${D}/${sysconfdir}/pki/ca-trust/extracted/openssl
    install -d -m 755 ${D}/${sysconfdir}/pki/ca-trust/extracted/java
    install -d -m 755 ${D}/${sysconfdir}/pki/ca-trust/extracted/edk2
    install -d -m 755 ${D}/${datadir}/pki/ca-trust-source
    install -d -m 755 ${D}/${datadir}/pki/ca-trust-source/anchors
    install -d -m 755 ${D}/${datadir}/pki/ca-trust-source/blacklist
    install -d -m 755 ${D}/${datadir}/pki/ca-trust-legacy
    install -d -m 755 ${D}/${bindir}

    install -p -m 644 ca-certificates/ca-bundle.trust.p11-kit ${D}/${datadir}/pki/ca-trust-source/ca-bundle.trust.p11-kit

    install -p -m 644 ca-certificates/ca-bundle.legacy.default.crt ${D}/${datadir}/pki/ca-trust-legacy/ca-bundle.legacy.default.crt
    install -p -m 644 ca-certificates/ca-bundle.legacy.disable.crt ${D}/${datadir}/pki/ca-trust-legacy/ca-bundle.legacy.disable.crt

    install -p -m 644 ${S}/ca-legacy.conf ${D}/${sysconfdir}/pki/ca-trust/ca-legacy.conf

    touch -r ${S}/certdata.txt ${D}/${datadir}/pki/ca-trust-source/ca-bundle.trust.p11-kit

    touch -r ${S}/certdata.txt ${D}/${datadir}/pki/ca-trust-legacy/ca-bundle.legacy.default.crt
    touch -r ${S}/certdata.txt ${D}/${datadir}/pki/ca-trust-legacy/ca-bundle.legacy.disable.crt

    # TODO: consider to dynamically create the update-ca-trust script from within
    #       this .spec file, in order to have the output file+directory names at once place only.
    install -p -m 755 ${S}/update-ca-trust ${D}/${bindir}/update-ca-trust

    install -p -m 755 ${S}/ca-legacy ${D}/${bindir}/ca-legacy

    # touch ghosted files that will be extracted dynamically
    # Set chmod 444 to use identical permission
    touch ${D}/${sysconfdir}/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
    chmod 444 ${D}/${sysconfdir}/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
    touch ${D}/${sysconfdir}/pki/ca-trust/extracted/pem/email-ca-bundle.pem
    chmod 444 ${D}/${sysconfdir}/pki/ca-trust/extracted/pem/email-ca-bundle.pem
    touch ${D}/${sysconfdir}/pki/ca-trust/extracted/pem/objsign-ca-bundle.pem
    chmod 444 ${D}/${sysconfdir}/pki/ca-trust/extracted/pem/objsign-ca-bundle.pem
    touch ${D}/${sysconfdir}/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt
    chmod 444 ${D}/${sysconfdir}/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt
    touch ${D}/${sysconfdir}/pki/ca-trust/extracted/java/cacerts
    chmod 444 ${D}/${sysconfdir}/pki/ca-trust/extracted/java/cacerts
    touch ${D}/${sysconfdir}/pki/ca-trust/extracted/edk2/cacerts.bin
    chmod 444 ${D}/${sysconfdir}/pki/ca-trust/extracted/edk2/cacerts.bin

    # /etc/ssl/certs symlink for 3rd-party tools
    ln -s ../pki/tls/certs \
        ${D}/${sysconfdir}/ssl/certs
    # legacy filenames
    ln -s ${sysconfdir}/pki/ca-trust/extracted/pem/tls-ca-bundle.pem \
        ${D}/${sysconfdir}/pki/tls/cert.pem
    ln -s ${sysconfdir}/pki/ca-trust/extracted/pem/tls-ca-bundle.pem \
        ${D}/${sysconfdir}/pki/tls/certs/ca-bundle.crt
    ln -s ${sysconfdir}/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt \
        ${D}/${sysconfdir}/pki/tls/certs/ca-bundle.trust.crt
    ln -s ${sysconfdir}/pki/ca-trust/extracted/java/cacerts \
        ${D}/${sysconfdir}/pki/java/cacerts
}

# From the source code of these two scripts,
# we can know that they should be executed on target,
# so certificates can be extracted to the target rootfs.
pkg_postinst_ontarget_${PN} () {
    ${bindir}/ca-legacy install
    ${bindir}/update-ca-trust
}

FILES_${PN} = " \
${sysconfdir}/pki/tls \
${sysconfdir}/pki/tls/certs \
${sysconfdir}/pki/java \
${sysconfdir}/pki/ca-trust \
${sysconfdir}/pki/ca-trust/source \
${sysconfdir}/pki/ca-trust/source/anchors \
${sysconfdir}/pki/ca-trust/source/blacklist \
${sysconfdir}/pki/ca-trust/extracted \
${sysconfdir}/pki/ca-trust/extracted/pem \
${sysconfdir}/pki/ca-trust/extracted/openssl \
${sysconfdir}/pki/ca-trust/extracted/java \
${datadir}/pki/ca-trust-source \
${datadir}/pki/ca-trust-source/anchors \
${datadir}/pki/ca-trust-source/blacklist \
${datadir}/pki/ca-trust-legacy \
\
${sysconfdir}/pki/ca-trust/ca-legacy.conf \
"
# symlinks for old locations
FILES_${PN} += " \
${sysconfdir}/pki/tls/cert.pem \
${sysconfdir}/pki/tls/certs/ca-bundle.crt \
${sysconfdir}/pki/tls/certs/ca-bundle.trust.crt \
${sysconfdir}/pki/java/cacerts \
"
# symlink directory
FILES_${PN} += " \
${sysconfdir}/ssl/certs \
"

# master bundle file with trust
FILES_${PN} += " \
${datadir}/pki/ca-trust-source/ca-bundle.trust.p11-kit \
"
FILES_${PN} += " \
${datadir}/pki/ca-trust-legacy/ca-bundle.legacy.default.crt \
${datadir}/pki/ca-trust-legacy/ca-bundle.legacy.disable.crt \
"
# update/extract tool
FILES_${PN} += " \
${bindir}/update-ca-trust \
${bindir}/ca-legacy \
${sysconfdir}/pki/ca-trust/source/ca-bundle.legacy.crt \
"
# files extracted files
FILES_${PN} += " \
${sysconfdir}/pki/ca-trust/extracted/pem/tls-ca-bundle.pem \
${sysconfdir}/pki/ca-trust/extracted/pem/email-ca-bundle.pem \
${sysconfdir}/pki/ca-trust/extracted/pem/objsign-ca-bundle.pem \
${sysconfdir}/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt \
${sysconfdir}/pki/ca-trust/extracted/java/cacerts \
${sysconfdir}/pki/ca-trust/extracted/edk2/cacerts.bin \
"

RDEPENDS_${PN} += "p11-kit"