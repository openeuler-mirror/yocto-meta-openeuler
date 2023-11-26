# main bbfile: yocto-poky/meta/recipes-kernel/systemtap/systemtap_git.bb

OPENEULER_SRC_URI_REMOVE = "git"

PV = "4.9"

# in 4.9, the following patches are already merged
SRC_URI:remove = " file://0001-PR28778-gcc-warning-tweak-for-sprintf-precision-para.patch \
                   file://0001-PR28804-tune-default-stap-s-buffer-size-on-small-RAM.patch \
                   file://0001-gcc12-c-compatibility-re-tweak-for-rhel6-use-functio.patch \
                 "

# from yocto-4.3's systemtap_git.bb (version = 4.9)
# | ../git/elaborate.cxx:2601:21: error: storing the address of local variable 'sym' in '*s.systemtap_session::symbol_resolver' [-Werror=dangling-pointer=]
CXXFLAGS += "-Wno-dangling-pointer"

# src package and patches from openEuler
SRC_URI:prepend = " \
        file://${BP}.tar.gz \
        "

S = "${WORKDIR}/${BP}"
