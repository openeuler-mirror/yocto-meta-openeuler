PV = "2025.9.11.17"
require pypi-src-openeuler.inc

# the src repo renamed the tarball to the pypi style
# (trove_classifiers-... instead of trove-classifiers-...);
# keep the repo directory mapping on the hyphenated name
PYPI_PACKAGE = "trove_classifiers"
OPENEULER_LOCAL_NAME = "python-trove-classifiers"

SRC_URI[sha256sum] = "931ca9841a5e9c9408bc2ae67b50d28acf85bef56219b56860876dd1f2d024dd"
SRC_URI:remove = "file://run-ptest"
