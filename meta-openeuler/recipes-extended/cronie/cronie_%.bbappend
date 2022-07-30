PV = "1.5.7"

SRC_URI += " \
    file://bugfix-cronie-systemd-alias.patch \
"

SRC_URI[md5sum] = "544f141aa4e34e0a176529be08441756"
SRC_URI[sha256sum] = "538bcfaf2e986e5ae1edf6d1472a77ea8271d6a9005aee2497a9ed6e13320eb3"

# current we not enable sysvint in DISTRO_FEATURES, just use busybox's init, but we want populate_packages_updatercd to work.
# In other word, we want update-rc.d always work when INITSCRIPT_NAME and INITSCRIPT_PARAMS generate with all none systemd scene.
# update-rc.d config from yocto-poky/meta/recipes-extended/cronie/cronie_1.5.5.bb:
# INITSCRIPT_NAME = "crond"
# INITSCRIPT_PARAMS = "start 90 2 3 4 5 . stop 60 0 1 6 ."
PACKAGESPLITFUNCS_prepend = "${@bb.utils.contains('DISTRO_FEATURES', 'systemd', '', 'populate_packages_updatercd ', d)}"

