SRC_URI += " \
    file://CVE-2015-9019.patch \
    file://Fix-variable-syntax-in-Python-configuration.patch \
    file://Fix-clang-Wconditional-uninitialized-warning-in-libx.patch \
    file://Fix-clang-Wimplicit-int-conversion-warning.patch \
    file://Fix-implicit-int-conversion-warning-in-exslt-crypto..patch \
    file://Fix-quadratic-runtime-with-text-and-xsl-message.patch \
    file://Fix-double-free-with-stylesheets-containing-entity-n.patch \
    file://Fix-use-after-free-in-xsltApplyTemplates.patch \
"

SRC_URI[md5sum] = "a96b227436c0f394a59509fc7bfefcb4"
SRC_URI[sha256sum] = "9a1af553b0bed564f0fb48c0902c4ef298cb21afc719f45ec52dbbcdd6fbe974"
