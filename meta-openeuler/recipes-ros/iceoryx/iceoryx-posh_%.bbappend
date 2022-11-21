# make ros libs compatible with lib64
do_configure:prepend:class-target() {
    if [[ "${libdir}" =~ "lib64" ]]; then
        cat ${S}/cpptoml-upstream/cpptoml.doxygen.in | grep "\"lib64\"" || sed -i 's:\"lib\":\"lib64\":g' ${S}/cpptoml-upstream/cpptoml.doxygen.in
        cat ${S}/cpptoml-upstream/CMakeLists.txt | grep "lib64/cmake/cpptoml" || sed -i 's:lib/cmake/cpptoml:lib64/cmake/cpptoml:g' ${S}/cpptoml-upstream/CMakeLists.txt
        cat ${S}/cmake/cpptoml/CMakeLists.txt | grep "lib64/cmake/cpptoml" || sed -i 's:lib/cmake/cpptoml:lib64/cmake/cpptoml:g' ${S}/cmake/cpptoml/CMakeLists.txt
    fi
}

