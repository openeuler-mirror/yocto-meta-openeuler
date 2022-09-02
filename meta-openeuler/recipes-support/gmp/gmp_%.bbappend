# use openeuler's cve patch
SRC_URI_remove += " \
        file://cve-2021-43618.patch \
        "

SRC_URI += "file://0001-CVE-2021-43618.patch \
"
