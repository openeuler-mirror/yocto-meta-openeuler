PV = "0.5"
require pypi-src-openeuler.inc

SRC_URI[md5sum] = "2054bab923df21107652d009f2373789"
SRC_URI[sha256sum] = "932e5239d526e7acb504017bb707be67019ac428a6932368e6851691093aa842"

# delete useless patch for version 0.4
SRC_URI:remove = "file://0001-Add-python-3-compatibility.patch "

SRC_URI:prepend = "file://backport-fix-bug-in-classifiers.patch "

# fix ModuleNotFoundError: No module named 'setuptools'
inherit setuptools3
