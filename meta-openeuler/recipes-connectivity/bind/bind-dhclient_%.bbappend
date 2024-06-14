# source bb: meta-overc/recipes-connectivity/bind/bind-dhclient_9.11.22.bb
OPENEULER_REPO_NAME = "dhcp"

# version in openeuler/dhcp
PV = "9.11.36"
DHCP_PV = "4.4.3"

# fix LIC_FILES_CHKSUM error
LIC_FILES_CHKSUM = "file://COPYRIGHT;md5=b88e7ca5f21908e1b2720169f6807cf6"

SRC_URI_remove = "https://ftp.isc.org/isc/bind9/${PV}/${PACKAGE_FETCH_NAME}-${PV}.tar.gz \
"

S = "${WORKDIR}/dhcp-${DHCP_PV}/bind/bind-${PV}"

# apply openEuler/dhcp patches
SRC_URI_prepend = "file://dhcp-${DHCP_PV}.tar.gz;name=dhcp.tarball \
           file://backport-0025-bind-Detect-system-time-changes.patch;striplevel=3 \
           file://backport-Fix-CVE-2021-25220.patch;striplevel=3 \
           file://backport-CVE-2022-2795.patch;striplevel=3 \
           file://backport-CVE-2022-38177.patch;striplevel=3 \
           file://backport-CVE-2022-38178.patch;striplevel=3 \
"

SRC_URI[dhcp.tarball.sha256sum] = "0e3ec6b4c2a05ec0148874bcd999a66d05518378d77421f607fb0bc9d0135818"

# bind users do not need shell/login access for secure
USERADD_PARAM_${PN} = "--system --home ${localstatedir}/cache/bind --no-create-home \
                       --shell /sbin/nologin --user-group bind"

# decompress the source code from dhcp-${DHCP_PV}.tar.gz
do_unpack_bind () {
        tar -xf bind.tar.gz
}
do_unpack_bind[dirs] = "${WORKDIR}/dhcp-${DHCP_PV}/bind/"

addtask unpack_bind after do_unpack before do_patch
