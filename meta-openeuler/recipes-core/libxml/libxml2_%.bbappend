# version in openEuler
PV = "2.9.14"

OPENEULER_SRC_URI_REMOVE = "git https http"

# remove patches can't apply
SRC_URI:remove = " \
           file://CVE-2022-40303.patch \
           file://CVE-2022-40304.patch \
           "

# apply openEuler source package
SRC_URI:prepend = "file://${BP}.tar.xz \
           file://libxml2-multilib.patch \
           file://backport-Rework-validation-context-flags.patch \
           file://backport-Remove-unneeded-code-in-xmlreader.c.patch \
           file://backport-Don-t-add-IDs-containing-unexpanded-entity-reference.patch \
           file://backport-Only-warn-on-invalid-redeclarations-of-predefined-en.patch \
           file://backport-Add-XML_DEPRECATED-macro.patch \
           file://Fix-memleaks-in-xmlXIncludeProcessFlags.patch \
           file://Fix-memory-leaks-for-xmlACatalogAdd.patch \
           file://Fix-memory-leaks-in-xmlACatalogAdd-when-xmlHashAddEntry-failed.patch \
           file://backport-CVE-2022-40303-Fix-integer-overflows-with-XML_PARSE_.patch \
           file://backport-CVE-2022-40304-Fix-dict-corruption-caused-by-entity-.patch \
           file://backport-schemas-Fix-null-pointer-deref-in-xmlSchemaCheckCOSS.patch \
           file://backport-parser-Fix-potential-memory-leak-in-xmlParseAttValue.patch \
           "


# remove python config, because openEuler not support python yet.
PACKAGECONFIG = "${@bb.utils.contains('DISTRO_FEATURES', 'python', 'python3', '', d)} \
		 ${@bb.utils.filter('DISTRO_FEATURES', 'ipv6', d)} \
"

# remove test configuration, because test package not in openEuler
do_configure:remove() {
	find ${S}/xmlconf/ -type f -exec chmod -x {} \+
}