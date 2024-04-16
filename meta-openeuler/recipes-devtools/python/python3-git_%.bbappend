require pypi-src-openeuler.inc

PV = "3.1.42"

SRC_URI:remove = "file://0001-python3-git-CVE-2022-24439-fix-from-PR-1518.patch \
            file://0001-python3-git-CVE-2022-24439-fix-from-PR-1521.patch \
           "

SRC_URI[sha256sum] = "8d9b8cb1e80b9735e8717c9362079d3ce4c6e5ddeebedd0361b228c3a67a62f6"
