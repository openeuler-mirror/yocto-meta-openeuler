PV = "4.0.2"
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

# openeuler add patches to change pcre to pcre2, no apply
SRC_URI_remove = "file://0001-Add-Node-7.x-aka-V8-5.2-support.patch \
            file://swig-3.0.12-Coverity-fix-issue-reported-for-SWIG_Python_FixMetho.patch \
            file://Python-Fix-new-GCC8-warnings-in-generated-code.patch \
            file://0001-Fix-generated-code-for-constant-expressions-containi.patch \
            "

SRC_URI[md5sum] = "7c3e46cb5af2b469722cafa0d91e127b"
SRC_URI[sha256sum] = "d53be9730d8d58a16bf0cbd1f8ac0c0c3e1090573168bfa151b01eb47fa906fc"
