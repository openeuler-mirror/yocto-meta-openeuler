OPENEULER_REPO_NAME = "docbook-dtds"

SRC_URI:prepend = "file://docbkx412.zip;subdir=docbook-4.1.2 \
           file://docbook-xml-4.2.zip;subdir=docbook-4.2 \
           file://docbook-xml-4.3.zip;subdir=docbook-4.3 \
           file://docbook-xml-4.4.zip;subdir=docbook-4.4 \
           file://docbook-xml-${PV}.zip;subdir=docbook-4.5 \
           "

SRC_URI[sha256sum] = "4e4e037a2b83c98c6c94818390d4bdd3f6e10f6ec62dd79188594e26190dc7b4"

S = "${WORKDIR}"

# no 4.0 version
do_install () {
    install -d ${D}${sysconfdir}/xml/
    xmlcatalog --create --noout ${D}${sysconfdir}/xml/docbook-xml.xml

    for DTDVERSION in 4.1.2 4.2 4.3 4.4 4.5; do
        DEST=${datadir}/xml/docbook/schema/dtd/$DTDVERSION
        install -d -m 755 ${D}$DEST
        cp -v -R docbook-$DTDVERSION/* ${D}$DEST
        xmlcatalog --verbose --noout --add nextCatalog unused \
          file://$DEST/catalog.xml ${D}${sysconfdir}/xml/docbook-xml.xml
    done
}
