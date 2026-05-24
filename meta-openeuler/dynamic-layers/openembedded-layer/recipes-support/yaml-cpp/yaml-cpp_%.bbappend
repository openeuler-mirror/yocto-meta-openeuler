# main bbfile: yocto-meta-openembedded/meta-oe/recipes-support/yaml-cpp/yaml-cpp_0.7.0.bb

# version in openEuler
PV = "0.9.0"
S = "${WORKDIR}/yaml-cpp-yaml-cpp-${PV}"

# files that come from openeuler (no patches in 0.9.0)
SRC_URI = " \
    file://${BP}.tar.gz \
"

# add -fPIC to solve dangerous relocation issues
OECMAKE_CXX_FLAGS += " -fPIC "
OECMAKE_C_FLAGS += " -fPIC "

EXTRA_OECMAKE += " -DYAML_BUILD_SHARED_LIBS=ON -DYAML_CPP_BUILD_TESTS=OFF -DYAML_CPP_BUILD_TOOLS=OFF -DYAML_CPP_BUILD_CONTRIB=OFF"
