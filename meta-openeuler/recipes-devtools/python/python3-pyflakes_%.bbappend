PV = "2.3.1"
LIC_FILES_CHKSUM = "file://LICENSE;md5=690c2d09203dc9e07c4083fc45ea981f"
SRC_URI[md5sum] = "0b60a307a6b293ee505fe0134e9d46e9"
SRC_URI[sha256sum] = "f5bc8ecabc05bb9d291eb5203d6810b49040f6ff446a756326104746cc00c1db"
require pypi-src-openeuler.inc
OPENEULER_REPO_NAME = "pyflakes"

SRC_URI +=" \
    file://0001-Detect-typing-module-attributes-with-import-typing-a.patch \
    file://0001-remove-old-and-unused-tracing-code-625.patch \
"
