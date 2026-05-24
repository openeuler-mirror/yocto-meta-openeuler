
PV = "3.7.1"

# openeuler src
SRC_URI:prepend = "file://${BP}.tar.gz "

SRC_URI[sha256sum] = "5d24e40819768f74daf846b99837fc53a3a9dcdf3ce1c2003fe0596db850f0f0"

FILESEXTRAPATHS:append := "${THISDIR}/${BPN}/:"

# configurehack.patch from base recipe applies with fuzz on 3.8.7 (type checks
# are already correctly positioned in openEuler configure.ac)
# All CVE patches below were backported into the openEuler 3.8.7 source
SRC_URI:remove = "file://configurehack.patch"

# patches from scarthgap recipe that don't apply to openeuler 3.8.7 source
SRC_URI:remove = "         file://CVE-2025-5914.patch         file://CVE-2025-5915.patch         file://CVE-2025-5916.patch         file://CVE-2025-5917.patch         file://CVE-2025-5918-0001.patch         file://CVE-2025-5918-0002.patch         file://CVE-2025-5918-0003.patch         file://0001-Merge-pull-request-2696-from-al3xtjames-mkstemp.patch         file://0001-Merge-pull-request-2749-from-KlaraSystems-des-tempdi.patch         file://0001-Merge-pull-request-2753-from-KlaraSystems-des-temp-f.patch         file://0001-Merge-pull-request-2768-from-Commandoss-master.patch         file://CVE-2025-60753-01.patch         file://CVE-2025-60753-02.patch         file://CVE-2026-4111-1.patch         file://CVE-2026-4111-2.patch         file://CVE-2026-4426.patch "

PACKAGECONFIG:remove = "lzo"

