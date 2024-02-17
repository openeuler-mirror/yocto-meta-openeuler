PV = "5.0.2"

SRC_URI = " \
        file://${BP}.tar.gz \
        file://0001-iSulad-add-json-files-and-adapt-to-meson.patch \
        file://0002-iSulad-adapt-security-conf-attach-cgroup-and-start.patch \
        file://0003-iSulad-adapt-conf-network-storage-and-termianl.patch \
        file://0004-iSulad-adapt-confile-lxccontainer-and-start.patch \
        file://0005-fix-compile-error.patch \
        file://0006-remove-isulad_cgfsng.patch \
        file://0007-fix-run-container-failed-when-enable-isulad.patch \
"

# FROM meta-virtualization
SRC_URI:append = " \
        file://lxc-net \
        file://dnsmasq.conf \
"

S = "${WORKDIR}/${BP}"

# Remove some operational dependencies as we do not yet support full functionality.
RDEPENDS:${PN}:remove = " \
		bridge-utils \
		dnsmasq \
		perl-module-strict \
		perl-module-getopt-long \
		perl-module-vars \
		perl-module-exporter \
		perl-module-constant \
		perl-module-overload \
		perl-module-exporter-heavy \
		libidn \
"

# According to the lxc.spec of src-openEuler, add DEPENDS
DEPENDS += " \
        yajl libseccomp libcap \
        libselinux \
        ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd', '', d)} \
"

EXTRA_OEMESON += "-Disulad=true"

# add "-L{sysroot}/lib64" to search libcap
TARGET_LDFLAGS += "-L${STAGING_BASELIBDIR}"
