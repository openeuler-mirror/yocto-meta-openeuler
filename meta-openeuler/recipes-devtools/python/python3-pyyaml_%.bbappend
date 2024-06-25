# the latest commit of PyYAML in branch openEuler-22.03-LTS-SP4 has version 6.0
# however, after comparing to the bb files in upstream community, we can find that
# compiling PyYAML 6.0 requires Yocto 4.0+ version.
# the latest version Yocto 3.3.x can support is PyYAML 5.4.1.
PV = "5.4.1"
OPENEULER_REPO_NAME = "${PYPI_PACKAGE}"
SRC_URI_remove += "${PYPI_SRC_URI} "
SRC_URI_prepend += "file://PyYAML-${PV}.tar.gz "
