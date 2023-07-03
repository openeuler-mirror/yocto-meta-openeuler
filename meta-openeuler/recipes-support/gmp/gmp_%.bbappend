# use openeuler's cve patch
SRC_URI:remove = " \
        file://cve-2021-43618.patch \
        "

SRC_URI:prepend = "file://0001-CVE-2021-43618.patch \
"
