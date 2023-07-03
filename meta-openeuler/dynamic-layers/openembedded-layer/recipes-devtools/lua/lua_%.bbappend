# the main bb file: yocto-poky/meta/recipes-devtools/lua/lua_5.4.4.bb

# remove patches out of date
SRC_URI:remove = "http://www.lua.org/ftp/lua-${PV}.tar.gz;name=tarballsrc \
"

# openeuler has patches for lua-${PV}-tests
SRC_URI:prepend = " \
           file://${BP}.tar.gz;name=tarballsrc \
"
# the follow openeuler patchs apply failed
# file://lua-5.4.0-beta-autotoolize.patch
# file://lua-5.3.0-idsize.patch
# file://lua-5.2.2-configure-linux.patch
# file://lua-5.3.0-configure-compat-module.patch
# file://backport-CVE-2022-28805.patch
# file://backport-CVE-2022-33099.patch
# file://backport-luaV_concat-can-use-invalidated-pointer-to-stack.patch

SRC_URI[tarballsrc.md5sum] = "bd8ce7069ff99a400efd14cf339a727b"
SRC_URI[tarballsrc.sha256sum] = "164c7849653b80ae67bec4b7473b884bf5cc8d2dca05653475ec2ed27b9ebf61"
SRC_URI[tarballtest.md5sum] = "0e28a9b48b3596d6b12989d04ae403c4"
SRC_URI[tarballtest.sha256sum] = "04d28355cd67a2299dfe5708b55a0ff221ccb1a3907a3113cc103ccc05ac6aad"
