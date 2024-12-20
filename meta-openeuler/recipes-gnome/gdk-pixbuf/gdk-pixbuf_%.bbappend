PV = "2.42.10"

SRC_URI:prepend = " file://${BP}.tar.xz \ 
file://backport-CVE-2022-48622.patch \
"
