# version in openEuler
PV = "2.9.14"

# remove patches can't apply
SRC_URI_remove = "http://www.xmlsoft.org/sources/libxml2-${PV}.tar.gz;name=libtar \
           	  http://www.w3.org/XML/Test/xmlts20080827.tar.gz;subdir=${BP};name=testtar \
		  file://libxml-m4-use-pkgconfig.patch \
		  file://0001-Make-ptest-run-the-python-tests-if-python-is-enabled.patch \
		  file://CVE-2020-7595.patch \
		  file://CVE-2019-20388.patch \
		  file://CVE-2020-24977.patch \
		  file://fix-python39.patch \
           	  file://CVE-2021-3517.patch \
           	  file://CVE-2021-3516.patch \
           	  file://CVE-2021-3518-0001.patch \
           	  file://CVE-2021-3518-0002.patch \
           	  file://CVE-2021-3537.patch \
           	  file://CVE-2021-3541.patch \
"

# apply openEuler source package
SRC_URI_prepend = "file://libxml2/${BP}.tar.xz \
"

# add patches in openEuler
SRC_URI += " \
        file://Fix-memleaks-in-xmlXIncludeProcessFlags.patch \
        file://Fix-memory-leaks-for-xmlACatalogAdd.patch \
        file://Fix-memory-leaks-in-xmlACatalogAdd-when-xmlHashAddEntry-failed.patch \
"

# checksum changed
SRC_URI[sha256sum] = "60d74a257d1ccec0475e749cba2f21559e48139efba6ff28224357c7c798dfee"

LIC_FILES_CHKSUM = "file://Copyright;md5=2044417e2e5006b65a8b9067b683fcf1 \
                    file://hash.c;beginline=6;endline=15;md5=e77f77b12cb69e203d8b4090a0eee879 \
                    file://list.c;beginline=4;endline=13;md5=b9c25b021ccaf287e50060602d20f3a7 \
                    file://trio.c;beginline=5;endline=14;md5=cd4f61e27f88c1d43df112966b1cd28f \
"

# remove python config, because openEuler not support python yet.
PACKAGECONFIG = "${@bb.utils.contains('DISTRO_FEATURES', 'python', 'python3', '', d)} \
		 ${@bb.utils.filter('DISTRO_FEATURES', 'ipv6', d)} \
"

# remove test configuration, because test package not in openEuler
do_configure_remove() {
	find ${S}/xmlconf/ -type f -exec chmod -x {} \+
}
