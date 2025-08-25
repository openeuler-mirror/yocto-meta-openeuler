
PV = "22.1.2"

SRC_URI:prepend = "file://${BP}.tar.xz \
  file://0001-fix-CVE-2024-31080.patch \
  file://0002-fix-CVE-2024-31081.patch \
  file://0003-fix-CVE-2023-6377.patch \
  file://0004-fix-CVE-2023-6478.patch \
  file://0005-fix-CVE-2023-6816.patch \
  file://0006-fix-CVE-2024-0408.patch \
  file://0007-fix-CVE-2024-0409.patch \
  file://0008-fix-CVE-2024-0229-1.patch \
  file://0009-fix-CVE-2024-0229-2.patch \
  file://0010-fix-CVE-2024-0229-3.patch \
  file://0011-fix-CVE-2024-31083.patch \
           "

DEPENDS += "libtirpc"
