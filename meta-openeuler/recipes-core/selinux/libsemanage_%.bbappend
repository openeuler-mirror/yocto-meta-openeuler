PV = "3.3"

OPENEULER_SRC_URI_REMOVE = "https git http"
SRC_URI_prepend = "file://${BP}.tar.gz \
        file://backport-libsemanage-do-not-sort-empty-records.patch \
        file://backport-libsemanage-tests-free-memory.patch \
        file://backport-libsemanage-Fall-back-to-semanage_copy_dir-when-rena.patch \
        file://backport-libsemanage-Fix-USE_AFTER_FREE-CWE-672-in-semanage_direct_get_module_info.patch \
        file://backport-libsemanage-avoid-double-fclose.patch \
        file://backport-libsemanage-fix-memory-leak-in-semanage_user_roles.patch \
        file://fix-test-failure-with-secilc.patch \
        "

SRC_URI[md5sum] = "a8b487ce862884bcf7dd8be603d4a6d4"
SRC_URI[sha256sum] = "93b423a21600b8e3fb59bb925d4583d1258f45bebf63c29bde304dfd3d52efd6"

S = "${WORKDIR}/${BP}"
