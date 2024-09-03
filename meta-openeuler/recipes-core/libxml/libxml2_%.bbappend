# version in openEuler
PV = "2.12.6"

# remove all poky patches for 2.11.4 and apply openEuler source package
SRC_URI = "file://${BP}.tar.xz \
           file://libxml2-multilib.patch \
           file://backport-CVE-2024-34459.patch \
           file://backport-CVE-2024-40896.patch \
           "

LIC_FILES_CHKSUM = "file://Copyright;md5=fec7ecfe714722b2bb0aaff7d200c701 \
                    file://hash.c;beginline=6;endline=15;md5=9af9349d0ead24569dc332f2116ef5f8 \
                    file://list.c;beginline=4;endline=13;md5=b9c25b021ccaf287e50060602d20f3a7 \
                    file://trio.c;beginline=5;endline=14;md5=cd4f61e27f88c1d43df112966b1cd28f"

# remove test configuration, because test package not in openEuler
do_configure:remove() {
	find ${S}/xmlconf/ -type f -exec chmod -x {} \+
}
