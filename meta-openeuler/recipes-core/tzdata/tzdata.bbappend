include timezone-append.inc

FILES:tzdata-core:append = " \
        ${datadir}/zoneinfo/Asia/Beijing        \
        ${datadir}/zoneinfo/Asia/Shanghai       \
"

SRC_URI:remove = "file://backport-Much-of-Greenland-still-uses-DST-from-2024-on.patch \
        file://bugfix-0001-add-Beijing-timezone.patch \
        file://remove-ROC-timezone.patch \
        file://rename-Macau-to-Macao.patch \
        file://remove-El_Aaiun-timezone.patch \
        file://remove-Israel-timezone.patch \
        file://skip-check_web-testcase.patch \
"

ASSUME_PROVIDE_PKGS = "tzdata"
