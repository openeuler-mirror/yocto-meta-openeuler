# On aarch64 openeuler, baselib = "lib64" so PYTHON_SITEPACKAGES_DIR resolves to
# ${libdir}/python3.x/site-packages = /usr/lib64/python3.x/site-packages.
# However meson's python module queries the Python interpreter's sysconfig which
# reports /usr/lib as the libdir, so files are installed under:
#   /usr/lib/python3.x/site-packages
# Add the /usr/lib path explicitly to FILES so the installed files are shipped.
FILES:${PN} += "${exec_prefix}/lib/${PYTHON_DIR}/site-packages"
