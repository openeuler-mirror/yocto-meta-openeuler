# main bb file: yocto-poky/meta/recipes-connectivity/bind/bind_9.16.16.bb

# version in openEuler
PV = "9.16.23"

# the file directory in poky is named bind-9.16.16
FILESEXTRAPATHS_prepend = "${THISDIR}/bind-9.16.16:"

# the patch is out of date, poky has updated it
SRC_URI_remove = "file://0001-named-lwresd-V-and-start-log-hide-build-options.patch \
"

# patch in openEuler
SRC_URI_prepend = "file://bind-9.5-PIE.patch \
           file://bind-9.16-redhat_doc.patch \
           file://bind93-rh490837.patch \
           file://bind97-rh645544.patch \
           file://bind-9.11-fips-tests.patch \
           file://bind-9.11-rh1666814.patch \
           file://backport-CVE-2022-0396.patch \
           file://backport-CVE-2021-25220.patch \
           file://bugfix-limit-numbers-of-test-threads.patch \
"

SRC_URI[sha256sum] = "dedb5e27aa9cb6a9ce3e872845887ff837b99e4e9a91a5e2fcd67cf6e1ef173c"

# version 9.16.23 done not have this directory
do_install_remove() {

	rmdir "${D}${localstatedir}/run"
	rmdir --ignore-fail-on-non-empty "${D}${localstatedir}"
}

