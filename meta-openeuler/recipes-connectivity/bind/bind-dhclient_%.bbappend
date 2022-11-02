# source bb: meta-overc/recipes-connectivity/bind/bind-dhclient_9.11.22.bb

# version in openeuler/dhcp
PV = "9.11.36"
DHCP_PV = "4.4.3"

# fix LIC_FILES_CHKSUM error
LIC_FILES_CHKSUM = "file://COPYRIGHT;md5=b88e7ca5f21908e1b2720169f6807cf6"

SRC_URI_remove = "https://ftp.isc.org/isc/bind9/${PV}/${PACKAGE_FETCH_NAME}-${PV}.tar.gz \
"

S = "${WORKDIR}/dhcp-${DHCP_PV}/bind/bind-${PV}"

# apply openEuler/dhcp patches
SRC_URI_prepend = "file://dhcp/dhcp-${DHCP_PV}.tar.gz;name=dhcp.tarball \
           file://dhcp/backport-0025-bind-Detect-system-time-changes.patch;striplevel=3 \
           file://dhcp/backport-Fix-CVE-2021-25220.patch;striplevel=3 \
"

SRC_URI[dhcp.tarball.sha256sum] = "1a7ccd64a16e5e68f7b5e0f527fd07240a2892ea53fe245620f4f5f607004521"

# bind users do not need shell/login access for secure
USERADD_PARAM_${PN} = "--system --home ${localstatedir}/cache/bind --no-create-home \
                       --shell /sbin/nologin --user-group bind"

# decompress the source code from dhcp-${DHCP_PV}.tar.gz
do_unpack_bind () {
        pushd ${WORKDIR}/dhcp-${DHCP_PV}/bind/
        tar -xf bind.tar.gz
        popd
}

addtask unpack_bind after do_unpack before do_patch
