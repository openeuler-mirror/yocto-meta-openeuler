PV = "3.6.1"

SRC_URI[sha256sum] = "c676146577d989189940f1959d9e3980d28513d74eedfbc6b7f15ea45fe54ee2"

# add patches from openeuler
SRC_URI += " \
    file://0001-Drop-rmd160-from-OpenSSL.patch \
    file://libarchive-uninitialized-value.patch \
"

#${STAGING_INCDIR_NATIVE}/ext2fs not exist when not building e2fsprogs-native
python() {
    openeuler_sysroot = d.getVar('OPENEULER_NATIVESDK_SYSROOT')
    if openeuler_sysroot:
       d.setVar('STAGING_INCDIR_NATIVE', "%s/usr/include" % openeuler_sysroot)
}
