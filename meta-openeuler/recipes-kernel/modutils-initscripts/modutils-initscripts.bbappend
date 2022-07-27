# main bbfile: yocto-poky/meta/recipes-kernel/modutils-initscripts/modutils-initscripts.bb

# current we not enable sysvint in DISTRO_FEATURES, just use busybox's init, but we want populate_packages_updatercd to work.
# In other word, we want update-rc.d always work when INITSCRIPT_NAME and INITSCRIPT_PARAMS generate with all none systemd scene.
PACKAGESPLITFUNCS_prepend = "${@bb.utils.contains('DISTRO_FEATURES', 'systemd', '', 'populate_packages_updatercd ', d)}"

