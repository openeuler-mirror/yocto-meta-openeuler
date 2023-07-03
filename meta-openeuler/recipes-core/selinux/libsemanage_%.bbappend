PV = "3.4"

SRC_URI:remove = "git://github.com/SELinuxProject/selinux.git;branch=master;protocol=https \
        file://libsemanage-allow-to-disable-audit-support.patch \
"

SRC_URI:prepend = "file://${BP}.tar.gz \
        file://fix-test-failure-with-secilc.patch \
        "

SRC_URI[md5sum] = "a8b487ce862884bcf7dd8be603d4a6d4"
SRC_URI[sha256sum] = "93b423a21600b8e3fb59bb925d4583d1258f45bebf63c29bde304dfd3d52efd6"

S = "${WORKDIR}/${BP}"
