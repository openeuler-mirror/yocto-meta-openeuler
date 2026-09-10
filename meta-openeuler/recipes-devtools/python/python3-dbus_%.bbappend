# Upstream recipe: yocto-poky/meta/recipes-devtools/python/python3-dbus_1.3.2.bb
# Source: https://atomgit.com/src-openeuler/dbus-python
# Pinned at 1.3.2 (openEuler-23.09/24.03/25.03 branch head), the same version
# as the upstream recipe
# The two spec patches (arch-specific module dir / deprecation warning cleanup)
# target RPM packaging only; yocto meson already installs to the right paths,
# so they are not carried here
OPENEULER_LOCAL_NAME = "dbus-python"

SRC_URI:prepend = " \
    file://dbus-python-${PV}.tar.gz \
"
