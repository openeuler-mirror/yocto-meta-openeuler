OPENEULER_SRC_URI_REMOVE = "http git"

PV = "3.7.1"

# openeuler src
SRC_URI:prepend = "file://${BP}.tar.gz \
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
