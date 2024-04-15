# main bbfile: yocto-meta-openembedded/meta-oe/recipes-support/yaml-cpp/yaml-cpp_0.7.0.bb

# version in openEuler
PV = "0.7.0"
S = "${WORKDIR}/yaml-cpp-yaml-cpp-${PV}"

# files, patches that come from openeuler
SRC_URI = " \
    file://${BP}.tar.gz \
    file://yaml-cpp-cmake.patch \
"

# add -fPIC to solve:
#   dangerous relocation: unsupported relocation
#   libyaml-cpp.a(nodebuilder.cpp.o): relocation R_AARCH64_ADR_PREL_PG_HI21 against symbol `_ZTVSt15_Sp_counted_ptrIPN4YAML6detail13memory_holderELN9__gnu_cxx12_Lock_policyE2EE' which may bind externally can not be used when making a shared object; recompile with -fPIC
OECMAKE_CXX_FLAGS += " -fPIC "
OECMAKE_C_FLAGS += " -fPIC "

EXTRA_OECMAKE += " -DYAML_BUILD_SHARED_LIBS=ON -DYAML_CPP_BUILD_TESTS=OFF -DYAML_CPP_BUILD_TOOLS=OFF -DYAML_CPP_BUILD_CONTRIB=OFF"
