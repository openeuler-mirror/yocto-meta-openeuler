PV = "0.8.3"

SRC_URI_remove = "file://determinism.patch"
SRC_URI_append = "file://backport-Make-Python-test-script-compatible-with-Python2-and-Python3.patch"

SRC_URI[sha256sum] = "bed6f6848e22bb2f83b5f764b2aef0ed393054e803a8e3a8711cb2a39e6b492d"