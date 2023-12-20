# python3-pbr Dependencies
PV = "3.8.0"

require pypi-src-openeuler.inc
OPENEULER_REPO_NAME = "python-flit"
# openeuler source
SRC_URI[sha256sum] = "d0f2a8f4bd45dc794befbf5839ecc0fd3830d65a57bd52b5997542fac5d5e937"
DEPENDS:remove:class-native = " python3-build-native"

#  There is a method that does not support this feature first, and it will be released after subsequent upgrades
# do_compile:class-native () {
#     python_flit_core_do_manual_build
# }
