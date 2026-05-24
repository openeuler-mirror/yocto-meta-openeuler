# python3-pbr Dependencies
# SP4 openeuler/python-flit has flit-3.8.0.tar.gz (not flit-core-*.tar.gz)
PV = "3.8.0"

require pypi-src-openeuler.inc
OPENEULER_LOCAL_NAME = "python-flit"
# pypi-src-openeuler.inc prepends file://flit-core-${PV}.tar.gz; override with correct name
SRC_URI:remove = "file://flit-core-${PV}.tar.gz"
SRC_URI:prepend = "file://flit-${PV}.tar.gz "
# openeuler source
SRC_URI[sha256sum] = "d0f2a8f4bd45dc794befbf5839ecc0fd3830d65a57bd52b5997542fac5d5e937"
DEPENDS:remove:class-native = " python3-build-native"

#  There is a method that does not support this feature first, and it will be released after subsequent upgrades
# do_compile:class-native () {
#     python_flit_core_do_manual_build
# }
