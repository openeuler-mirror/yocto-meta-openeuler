# openeuler PV
PV = "2.46.0"

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}/:"

# remove 2.35.7 poky patch
SRC_URI:remove = "file://CVE-2023-29007.patch \
                  file://CVE-2023-25652.patch \
                  file://backport-send-email-avoid-duplicate-specification-warnings.patch \
                 "


# 2.41.0 sha256sum
SRC_URI[tarball.sha256sum] = "b138811e16838f669a2516e40f09d50500e1c7fc541b5ab50ce84b98585e5230"

# openeuler SRC_URI
SRC_URI:prepend = "file://${BP}.tar.xz \
                  "

S = "${WORKDIR}/${BP}"

# 2.41.0 do_install
do_install () {
	oe_runmake install DESTDIR="${D}" bindir=${bindir} \
		template_dir=${datadir}/git-core/templates

	install -d ${D}/${datadir}/bash-completion/completions/
	install -m 644 ${S}/contrib/completion/git-completion.bash ${D}/${datadir}/bash-completion/completions/git

        if [ "${@bb.utils.filter('PACKAGECONFIG', 'manpages', d)}" ]; then
            # Needs to be serial with make 4.4 due to https://savannah.gnu.org/bugs/index.php?63362
            make install-man DESTDIR="${D}"
        fi
}

# 2.41.0 PERLTOOLS
PERLTOOLS:remove = " \
    ${libexecdir}/git-core/git-add--interactive \
"
