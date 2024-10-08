
PV = "3.7.1"

# openeuler src
SRC_URI:prepend = "file://${BP}.tar.gz \
            file://backport-CVE-2024-20697-CVE-2024-26256.patch \
            file://backport-CVE-2024-20696.patch \
           "

FILESEXTRAPATHS:append := "${THISDIR}/${BPN}/:"

# keep same as upstream
SRC_URI += "file://configurehack.patch"

PACKAGECONFIG:remove = "lzo"

# openeuler adapt
# ${STAGING_INCDIR_NATIVE}/ext2fs not exist when not building e2fsprogs-native
do_configure:prepend() {
    if [ "${OPENEULER_PREBUILT_TOOLS_ENABLE}" = "yes" ] && [ ! -d "${STAGING_INCDIR_NATIVE}/usr/include/ext2fs" ]; then
        install -d ${STAGING_INCDIR_NATIVE}/usr/include/ext2fs
	    cp -R ${OPENEULER_NATIVESDK_SYSROOT}/usr/include/ext2fs/ ${STAGING_INCDIR_NATIVE}/
    fi
}
