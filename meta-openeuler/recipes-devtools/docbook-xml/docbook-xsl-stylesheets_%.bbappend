
PV = "1.79.1"

inherit oee-archive

# upstream src and patches
SRC_URI:append = " file://docbook-xsl-${PV}.tar.bz2 \
           "

# 1.79.2 has conflict with shared-mime-info, no this version in openeuler
# FAILED: data/shared-mime-info-spec-html
# recipe-sysroot-native/usr/bin/xmlto -o data/shared-mime-info-spec-html html-nochunks ../shared-mime-info-2.2/data/shared-mime-info-spec.xml
# I/O error : Attempt to load network entity http://docbook.sourceforge.net/release/xsl/current/html/docbook.xsl
# upstream has no 1.79.2 recipe
