# this class contains global method and variables for openeuler embedded

# set_rpmdpes is used to set RPMDEPS which comes from nativesdk/host
python set_rpmdeps() {
    import subprocess
    rpmdeps  = subprocess.Popen('rpm --eval="%{_rpmconfigdir}"', shell=True, stdout=subprocess.PIPE)
    stdout, stderr = rpmdeps.communicate()
    d.setVar('RPMDEPS', os.path.join(str(stdout, "utf-8").strip(), "rpmdeps --alldeps --define '__font_provides %{nil}'"))
}

addhandler set_rpmdeps
set_rpmdeps[eventmask] = "bb.event.RecipePreFinalise"

# set BUILD_LDFLAGS for use nativesdk lib
BUILD_LDFLAGS_append = " -L${OPENEULER_NATIVESDK_SYSROOT}/usr/lib \
                         -L${OPENEULER_NATIVESDK_SYSROOT}/lib \
                         -Wl,-rpath-link,${OPENEULER_NATIVESDK_SYSROOT}/usr/lib \
                         -Wl,-rpath-link,${OPENEULER_NATIVESDK_SYSROOT}/lib \
                         -Wl,-rpath,${OPENEULER_NATIVESDK_SYSROOT}/usr/lib \
                         -Wl,-rpath,${OPENEULER_NATIVESDK_SYSROOT}/lib"
