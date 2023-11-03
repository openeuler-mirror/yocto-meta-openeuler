export KERNEL_SRC="${SDKTARGETSYSROOT}/usr/src/kernel"
OPENEULER_NATIVESDK_SYSROOT=/opt/buildtools/nativesdk/sysroots/x86_64-pokysdk-linux
# prepare SDK
PYTHONBIN=`which python3`
PYTHONVERSION=`python3 --version | awk -F "." '{print $2}'`
PYTHONPKGPATH="${PYTHONBIN%/*}/../lib/python3.${PYTHONVERSION}/site-packages/"
# auto add COLCON_WORK_PATH for toolchain.cmake, make colcon find pkg install from this path when build
alias colcon='export COLCON_WORK_PATH=`pwd`  && colcon'
if [ ${PYTHONPKGPATH#${OPENEULER_NATIVESDK_SYSROOT}} != "$PYTHONPKGPATH" ]; then
    # prepare context for kernel module development when using nativesdk
    pushd "${SDKTARGETSYSROOT}/usr/src/kernel"
    make modules_prepare PKG_CONFIG_SYSROOT_DIR= PKG_CONFIG_PATH= KBUILD_HOSTCFLAGS+="-L${OPENEULER_NATIVESDK_SYSROOT}/usr/lib \
                            -L${OPENEULER_NATIVESDK_SYSROOT}/lib \
                            -Wl,-rpath-link,${OPENEULER_NATIVESDK_SYSROOT}/usr/lib \
                            -Wl,-rpath-link,${OPENEULER_NATIVESDK_SYSROOT}/lib \
                            -Wl,-rpath,${OPENEULER_NATIVESDK_SYSROOT}/usr/lib \
                            -Wl,-rpath,${OPENEULER_NATIVESDK_SYSROOT}/lib"
    popd

    if test -d $PYTHONPKGPATH; then
        if test -d ${SDKTARGETSYSROOT}/usr/share/rosidl_cmake; then
            # prepare ROS SDK, only works in the ROS environment with our nativesdk.
            pushd $PYTHONPKGPATH
            # Here, we have a symbolic link for the Python package that is used by the ROS package
            # in the lib directory of our sysroot environment, instead of lib64.
            find . -type l -delete
            for file in ${SDKTARGETSYSROOT}/usr/lib/python3.*/site-packages/*
            do
                ln -sfnT "$file" "$(basename "$file")"
            done
            popd

            # Install host python tools
            python3 -m pip install -r $OECORE_NATIVE_SYSROOT/environment-setup.d/requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
            export CMAKE_TOOLCHAIN_FILE="$OECORE_NATIVE_SYSROOT/environment-setup.d/toolchain.cmake"
	    # avoid pythonpath err in colcon
            sed -i 's%python_path.exists():%python_path.exists() and not (\"\%s\" \% python_path).startswith("/opt/buildtools/nativesdk/sysroots/x86_64-pokysdk-linux/usr/lib"):%' ${OPENEULER_NATIVESDK_SYSROOT}/usr/lib/python3.*/site-packages/colcon_core/environment/pythonpath.py
        fi
	# add find_path cross compile support for numpy path
	sed -i '/_NumPy_PATH/{n; s%NO_DEFAULT_PATH)%NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH)%}' ${OPENEULER_NATIVESDK_SYSROOT}/usr/share/cmake-*/Modules/FindPython/Support.cmake
    fi
else
    # prepare context for kernel module development
    pushd "${SDKTARGETSYSROOT}/usr/src/kernel"
    make modules_prepare PKG_CONFIG_SYSROOT_DIR= PKG_CONFIG_PATH=
    popd
fi

