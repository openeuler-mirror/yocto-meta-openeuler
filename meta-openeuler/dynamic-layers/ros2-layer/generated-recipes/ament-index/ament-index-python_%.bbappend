# note: setuptools from PYTHONPATH, but the python will find lib in native path, it will case error
# so add sysconfigdata to PYTHONPATH
export PYTHONPATH="$PYTHONPATH:${RECIPE_SYSROOT}/usr/lib64/python-sysconfigdata"
