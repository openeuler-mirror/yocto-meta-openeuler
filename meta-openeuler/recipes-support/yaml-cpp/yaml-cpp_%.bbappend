# main bbfile: yocto-meta-openembedded/meta-oe/recipes-support/yaml-cpp/yaml-cpp_0.6.3.bb

OPENEULER_SRC_URI_REMOVE = "https git"
OPENEULER_REPO_NAME = "yaml-cpp"

# version in openEuler
PV = "0.6.3"
S = "${WORKDIR}/yaml-cpp-yaml-cpp-${PV}"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
"
# files, patches that come from openeuler
SRC_URI_prepend = " \
    file://yaml-cpp-${PV}.tar.gz \
    file://CVE-2017-5950.patch \
"
SRC_URI[md5sum] = "b45bf1089a382e81f6b661062c10d0c2"
SRC_URI[sha256sum] = "77ea1b90b3718aa0c324207cb29418f5bced2354c2e483a9523d98c3460af1ed"

# add -fPIC to solve:
#   dangerous relocation: unsupported relocation
#   libyaml-cpp.a(nodebuilder.cpp.o): relocation R_AARCH64_ADR_PREL_PG_HI21 against symbol `_ZTVSt15_Sp_counted_ptrIPN4YAML6detail13memory_holderELN9__gnu_cxx12_Lock_policyE2EE' which may bind externally can not be used when making a shared object; recompile with -fPIC
OECMAKE_CXX_FLAGS += " -fPIC "
OECMAKE_C_FLAGS += " -fPIC "

EXTRA_OECMAKE += " -DYAML_BUILD_SHARED_LIBS=ON -DYAML_CPP_BUILD_TESTS=OFF -DYAML_CPP_BUILD_TOOLS=OFF -DYAML_CPP_BUILD_CONTRIB=OFF"
