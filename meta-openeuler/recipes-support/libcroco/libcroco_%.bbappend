SRC_URI:prepend = " \
    file://${BP}.tar.gz \
    file://CVE-2017-8834_CVE-2017-8871.patch \
    file://backport-CVE-2020-12825-parser-limit-recursion-in-block-and-any-productions.patch \
"

SRC_URI:remove = " \
        file://CVE-2020-12825.patch \
"

DEPENDS:append:class-target = "${@' gtk-doc' if d.getVar('GTKDOC_ENABLED') == 'True' else ''}"

GTKDOC_MESON_OPTION = "gtk_doc"
