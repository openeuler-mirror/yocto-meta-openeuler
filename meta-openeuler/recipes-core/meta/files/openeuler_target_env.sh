export KERNEL_SRC="${SDKTARGETSYSROOT}/usr/src/kernel"
# prepare context for kernel module development
pushd "${SDKTARGETSYSROOT}/usr/src/kernel"
make modules_prepare PKG_CONFIG_SYSROOT_DIR= PKG_CONFIG_PATH=
popd

# prepare ROS SDK, only works in the ROS environment with our nativesdk.
PYTHONBIN=`which python3`
PYTHONPKGPATH="${PYTHONBIN%/*}/../lib/python3.9/site-packages/"
if [ ${PYTHONPKGPATH#/opt/buildtools/nativesdk/sysroots/x86_64-pokysdk-linux} != "$PYTHONPKGPATH" ]; then
    if test -d $PYTHONPKGPATH; then
        if test -d ${SDKTARGETSYSROOT}/usr/share/rosidl_cmake; then
            pushd $PYTHONPKGPATH
            # Here, we have a symbolic link for the Python package that is used by the ROS package
            # in the lib directory of our sysroot environment, instead of lib64.
            find . -type l -delete
            for file in ${SDKTARGETSYSROOT}/usr/lib/python3.9/site-packages/*
            do
                ln -sfnT "$file" "$(basename "$file")"
            done
            popd
            # Install host python tools
            python3 -m pip install -r $OECORE_NATIVE_SYSROOT/environment-setup.d/requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
            export CMAKE_TOOLCHAIN_FILE="$OECORE_NATIVE_SYSROOT/environment-setup.d/toolchain.cmake"
            # avoid pythonpath err in colcon
            sed -i 's%python_path.exists():%python_path.exists() and not (\"\%s\" \% python_path).startswith("/opt/buildtools/nativesdk/sysroots/x86_64-pokysdk-linux/usr/lib"):%' /opt/buildtools/nativesdk/sysroots/x86_64-pokysdk-linux/usr/lib/python3.*/site-packages/colcon_core/environment/pythonpath.py
        fi
        # add find_path cross compile support for numpy path
        sed -i '/_NumPy_PATH/{n; s%NO_DEFAULT_PATH)%NO_DEFAULT_PATH CMAKE_FIND_ROOT_PATH_BOTH)%}' /opt/buildtools/nativesdk/sysroots/x86_64-pokysdk-linux/usr/share/cmake-*/Modules/FindPython/Support.cmake
    fi
fi

