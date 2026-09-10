# main bbfile: yocto-meta-openembedded/meta-networking/recipes-support/libconfuse/libconfuse_3.3.bb
#
# consume the tarball from src-openeuler/libconfuse
# (https://atomgit.com/src-openeuler/libconfuse) instead of the github
# git repo, which drops the do_configure autogen.sh step; also apply
# the CVE fix carried in the src-openeuler spec
SRC_URI:remove = "git://github.com/libconfuse/libconfuse.git;branch=master;protocol=https"

SRC_URI:prepend = " \
    file://confuse-${PV}.tar.gz \
    file://CVE-2022-40320.patch;striplevel=0 \
"

SRC_URI[sha256sum] = "3a59ded20bc652eaa8e6261ab46f7e483bc13dad79263c15af42ecbb329707b8"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://0001-only-apply-search-path-logic-to-relative-pathnames.patch"

# the release tarball unpacks as confuse-${PV}
S = "${WORKDIR}/confuse-${PV}"

# genimage-native (phytium image generation) needs libconfuse-native;
# the retired phytium confuse recipe provided native/nativesdk
# variants, keep the same coverage here
BBCLASSEXTEND = "native nativesdk"

# no autogen.sh needed for the release tarball: create an empty one so
# that the do_configure:prepend autogen.sh step from the main bbfile
# (registered before ours, thus executed after) succeeds as a no-op
do_configure:prepend() {
    touch ${S}/autogen.sh
    chmod +x ${S}/autogen.sh
}
