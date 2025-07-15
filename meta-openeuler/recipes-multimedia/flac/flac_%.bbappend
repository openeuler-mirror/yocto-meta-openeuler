PV = "1.4.3"

SRC_URI = " \
    file://${BP}.tar.xz \
    file://flac-1.4.3-sw.patch \
    file://Limit-the-number-of-clock-calls.patch \
    file://Documentation-man-flac.md-fix-typo.patch \
    file://flac-foreign_metadata-fix-Walloc-size.patch \
    file://Fix-format-ending-up-with-wrong-subformat.patch \
"
