PV = "23.3.1"
LIC_FILES_CHKSUM:remove = "\
    file://src/pip/_vendor/pkg_resources/LICENSE;md5=9a33897f1bca1160d7aad3835152e158 \
    file://src/pip/_vendor/typing_extensions.LICENSE;md5=f16b323917992e0f8a6f0071bc9913e2 \
"

LIC_FILES_CHKSUM:prepend = "\
    file://src/pip/_vendor/pkg_resources/LICENSE;md5=141643e11c48898150daa83802dbc65f \
    file://src/pip/_vendor/typing_extensions.LICENSE;md5=fcf6b249c2641540219a727f35d8d2c2 \
"

SRC_URI[sha256sum] = "1fcaa041308d01f14575f6d0d2ea4b75a3e2871fe4f9c694976f908768e14174"
require pypi-src-openeuler.inc

# remove poky conflict patches
SRC_URI:remove = " \
        file://0001-change-shebang-to-python3.patch \
        file://0001-Don-t-split-git-references-on-unicode-separators.patch \
        file://reproducible.patch \
        "

# apply openeuler patches
SRC_URI:append =" \
        file://remove-existing-dist-only-if-path-conflicts.patch \
        file://dummy-certifi.patch \
        file://backport-CVE-2023-45803-Made-body-stripped-from-HTTP-requests.patch \
        file://backport-CVE-2024-37891-Strip-Proxy-Authorization-header-on-redirects.patch \
"
