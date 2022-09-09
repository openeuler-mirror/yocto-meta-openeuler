# source bb: meta-overc/recipes-connectivity/bind/bind-dhclient_9.11.22.bb

# version in openeuler/dhcp
PV = "9.11.14"

# fix LIC_FILES_CHKSUM error
LIC_FILES_CHKSUM = "file://COPYRIGHT;md5=8f17f64e47e83b60cd920a1e4b54419e"

SRC_URI_remove = "https://ftp.isc.org/isc/bind9/${PV}/${PACKAGE_FETCH_NAME}-${PV}.tar.gz \
"

# integrate the patch of a later version, apply openEuler/dhcp patch adapt
SRC_URI_prepend = "file://dhcp/dhcp-4.4.2.tar.gz;name=dhcp.tarball \
           file://backport-0025-bind-Detect-system-time-changes.patch \
           file://0001-revert-d10fbdec-for-lib-dns-gen.c-as-it-is-a-build-p.patch \
"

SRC_URI[dhcp.tarball.sha256sum] = "1a7ccd64a16e5e68f7b5e0f527fd07240a2892ea53fe245620f4f5f607004521"

# bind users do not need shell/login access for secure
USERADD_PARAM_${PN} = "--system --home ${localstatedir}/cache/bind --no-create-home \
                       --shell /sbin/nologin --user-group bind"

# decompress the source code from dhcp-4.4.2.tar.gz
do_unpack_bind () {
        cd ${WORKDIR}
        tar -xf dhcp-4.4.2/bind/bind.tar.gz
}

addtask unpack_bind after do_unpack before do_patch
