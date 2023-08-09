# main bbfile: yocto-poky/meta/recipes-bsp/opensbi/opensbi_0.9.bb

# apply openEuler package
OPENEULER_REPO_NAME = "opensbi"
OPENEULER_BRANCH    = "master"
OPENEULER_SRC_URI_REMOVE = "https git http"

PV = "0.9"

SRC_URI=  "file://v0.9.zip \
           file://0001-Enable-build-id-for-elf-files.patch \
          "

S = "${WORKDIR}/opensbi-${PV}"
