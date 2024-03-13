# we fetch the source code through openeuler_fetch.
# Thus, there are some common configurations needed to be changed.
include phosphor-settings-manager-src.inc

# we do not use git to download the source code
# so the variable ${SRCPV} is not set
# remove this variable from ${PV}
PV = "1.0"

# the source code repository fetched by openeuler_fetch
S = "${WORKDIR}/${OPENEULER_LOCAL_NAME}"

# by default the file merge_settings.py is not executable
# however the do_merge_settings task needs to execute it
do_configure:append () {
    chmod +x ${WORKDIR}/merge_settings.py
}
