# the bbclass is to alter setup.py about python package, when poky upgrade to 4.0, distutils functional has move to
# setuptools, so if there has `from distutil.core import setup`, it will occure error "invalid command 'bdist_wheel'"
# so in order to fix this error, we replace distutil.core to setuptools

inherit setuptools3

do_configure:append() {
    if [[ -f ${S}/setup.py ]];then
        pushd ${S}
        sed -i 's/from distutils.core import setup/from setuptools import setup/g' setup.py
        popd
    fi
}
