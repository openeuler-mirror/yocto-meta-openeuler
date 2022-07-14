# main bb file: yocto-poky/meta/recipes-connectivity/openssl/openssl_1.1.1k.bb

# openEuler version
PV = "1.1.1m"

# patches in openEuler
SRC_URI += "\
           file://openssl/openssl-1.1.1-build.patch \
           file://openssl/openssl-1.1.1-fips.patch \
	   file://0003-Add-support-for-io_pgetevents_time64-syscall.patch \
           file://0004-Fixup-support-for-io_pgetevents_time64-syscall.patch \
	   file://backport-Fix-NULL-pointer-dereference-for-BN_mod_exp2_mont.patch \
	   file://CVE-2022-0778-Add-a-negative-testcase-for-BN_mod_sqrt.patch \
	   file://CVE-2022-0778-Fix-possible-infinite-loop-in-BN_mod_sqrt.patch \
	   file://CVE-2022-1292.patch \
	   file://CVE-2022-2068-Fix-file-operations-in-c_rehash.patch \
	   file://CVE-2022-2097-Fix-AES-OCB-encrypt-decrypt-for-x86-AES-NI.patch \
"

SRC_URI[sha256sum] = "f89199be8b23ca45fc7cb9f1d8d3ee67312318286ad030f5316aca6462db6c96"

# if PACKAGECONFIG variant has perl, add perl RDEPENS
RDEPENDS_${PN}-misc = "${@bb.utils.contains('PACKAGECONFIG', 'perl', 'perl', '', d)}"
