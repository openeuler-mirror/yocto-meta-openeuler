def autotools_xxxx(d):
    if d.getVar('INHIBIT_AUTOTOOLS_DEPS'):
        return ''

    pn = d.getVar('PN')
    deps = ''

    if pn in ['autoconf-native', 'automake-native']:
        return deps
    deps += 'autoconf-native automake-native '

    if not pn in ['libtool', 'libtool-native'] and not pn.endswith("libtool-cross"):
        if not bb.data.inherits_class('native', d) \
                        and not bb.data.inherits_class('nativesdk', d) \
                        and not bb.data.inherits_class('cross', d) \
                        and not d.getVar('INHIBIT_DEFAULT_DEPS'):
            image_name = "%s%s" % (d.getVar('MACHINE_ARCH'), d.getVar('OPENEULER_KERNEL_TAG'))
            #if image_name in ['arm32a15eb-4.4', 'arm32a9eb-4.4', 'arm32a9eb-tiny-4.4', 'arm64eb-4.4']:
                #deps += ' '
            #else:
                #deps += 'libtool-cross '

    return deps + 'gnu-config-native '

DEPENDS_prepend = "${@autotools_xxxx(d)} "

inherit siteinfo

# Space separated list of shell scripts with variables defined to supply test
# results for autoconf tests we cannot run at build time.
# The value of this variable is filled in in a prefunc because it depends on
# the contents of the sysroot.
export CONFIG_SITE = "${@siteinfo_get_files(d)}"
acpaths ?= "default"
EXTRA_AUTORECONF_DEFINE = " AUTOPOINT=echo GTKDOCIZE=echo "

export lt_cv_sys_lib_dlsearch_path_spec = "${libdir} ${base_libdir}"

# When building tools for use at build-time it's recommended for the build
# system to use these variables when cross-compiling.
# (http://sources.redhat.com/autobook/autobook/autobook_270.html)
export CPP_FOR_BUILD = "${BUILD_CPP}"
export CPPFLAGS_FOR_BUILD = "${BUILD_CPPFLAGS}"

export CC_FOR_BUILD = "${BUILD_CC}"
export CFLAGS_FOR_BUILD = "${BUILD_CFLAGS}"

export CXX_FOR_BUILD = "${BUILD_CXX}"
export CXXFLAGS_FOR_BUILD="${BUILD_CXXFLAGS}"

export LD_FOR_BUILD = "${BUILD_LD}"
export LDFLAGS_FOR_BUILD = "${BUILD_LDFLAGS}"

def append_libtool_sysroot(d):
    # Only supply libtool sysroot option for non-native packages
    return ""

CONFIGUREOPTS = " --build=${BUILD_SYS} \
		  --host=${HOST_SYS} \
		  --target=${TARGET_SYS} \
		  --prefix=${prefix} \
		  --exec_prefix=${exec_prefix} \
		  --bindir=${bindir} \
		  --sbindir=${sbindir} \
		  --libexecdir=${libexecdir} \
		  --datadir=${datadir} \
		  --sysconfdir=${sysconfdir} \
		  --sharedstatedir=${sharedstatedir} \
		  --localstatedir=${localstatedir} \
		  --libdir=${libdir} \
		  --includedir=${includedir} \
		  --oldincludedir=${oldincludedir} \
		  --infodir=${infodir} \
		  --mandir=${mandir} \
		  --disable-silent-rules \
		  ${CONFIGUREOPT_DEPTRACK} \
		  ${@append_libtool_sysroot(d)}"
CONFIGUREOPT_DEPTRACK ?= "--disable-dependency-tracking"

CACHED_CONFIGUREVARS ?= ""

AUTOTOOLS_SCRIPT_PATH ?= "${S}"
CONFIGURE_SCRIPT ?= "${AUTOTOOLS_SCRIPT_PATH}/configure"

AUTOTOOLS_AUXDIR ?= "${AUTOTOOLS_SCRIPT_PATH}"

oe_runconf () {
	# Use relative path to avoid buildpaths in files
	cfgscript_name="`basename ${CONFIGURE_SCRIPT}`"
	cfgscript=`python3 -c "import os; print(os.path.relpath(os.path.dirname('${CONFIGURE_SCRIPT}'), '.'))"`/$cfgscript_name
	if [ -x "$cfgscript" ] ; then
		bbnote "Running $cfgscript ${CONFIGUREOPTS} ${EXTRA_OECONF} $@"
		if ! CONFIG_SHELL=/bin/bash ${CACHED_CONFIGUREVARS} $cfgscript ${CONFIGUREOPTS} ${EXTRA_OECONF} "$@"; then
			bbnote "The following config.log files may provide further information."
			bbnote `find ${B} -ignore_readdir_race -type f -name config.log`
			bbfatal_log "configure failed"
		fi
	else
		bbfatal "no configure script found at $cfgscript"
	fi
}

CONFIGURESTAMPFILE = "${WORKDIR}/configure.sstate"

autotools_preconfigure() {
	if [ -n "${CONFIGURESTAMPFILE}" -a -e "${CONFIGURESTAMPFILE}" ]; then
		if [ "`cat ${CONFIGURESTAMPFILE}`" != "${BB_TASKHASH}" ]; then
			if [ "${S}" != "${B}" ]; then
				echo "Previously configured separate build directory detected, cleaning ${B}"
				rm -rf ${B}
				mkdir -p ${B}
			else
				# At least remove the .la files since automake won't automatically
				# regenerate them even if CFLAGS/LDFLAGS are different
				cd ${S}
				if [ "${CLEANBROKEN}" != "1" -a \( -e Makefile -o -e makefile -o -e GNUmakefile \) ]; then
					oe_runmake clean
				fi
				find ${S} -ignore_readdir_race -name \*.la -delete
			fi
		fi
	fi
}

autotools_postconfigure(){
	if [ -n "${CONFIGURESTAMPFILE}" ]; then
		mkdir -p `dirname ${CONFIGURESTAMPFILE}`
		echo ${BB_TASKHASH} > ${CONFIGURESTAMPFILE}
	fi
}

EXTRACONFFUNCS ??= ""

EXTRA_OECONF_append = " ${PACKAGECONFIG_CONFARGS}"

do_configure[prefuncs] += "autotools_preconfigure autotools_aclocals ${EXTRACONFFUNCS}"
#do_compile[prefuncs] += "autotools_aclocals"
#do_install[prefuncs] += "autotools_aclocals"
do_configure[postfuncs] += "autotools_postconfigure"

ACLOCALDIR = "${STAGING_DATADIR}/aclocal"
ACLOCALEXTRAPATH = ""
ACLOCALEXTRAPATH_class-target = " -I ${STAGING_DATADIR_NATIVE}/aclocal/"
ACLOCALEXTRAPATH_class-nativesdk = " -I ${STAGING_DATADIR_NATIVE}/aclocal/"

python autotools_aclocals () {
    d.setVar("CONFIG_SITE", siteinfo_get_files(d, sysrootcache=True))
}

CONFIGURE_FILES = "${S}/configure.in ${S}/configure.ac ${S}/config.h.in ${S}/acinclude.m4 Makefile.am"

autotools_do_configure() {
	# WARNING: gross hack follows:
	# An autotools built package generally needs these scripts, however only
	# automake or libtoolize actually install the current versions of them.
	# This is a problem in builds that do not use libtool or automake, in the case
	# where we -need- the latest version of these scripts.  e.g. running a build
	# for a package whose autotools are old, on an x86_64 machine, which the old
	# config.sub does not support.  Work around this by installing them manually
	# regardless.

	PRUNE_M4=""

	for ac in `find ${S} -ignore_readdir_race -name configure.in -o -name configure.ac`; do
		rm -f `dirname $ac`/configure
	done
	if [ -e ${AUTOTOOLS_SCRIPT_PATH}/configure.in -o -e ${AUTOTOOLS_SCRIPT_PATH}/configure.ac ]; then
		olddir=`pwd`
		cd ${AUTOTOOLS_SCRIPT_PATH}
		mkdir -p ${ACLOCALDIR}
		if [ x"${acpaths}" = xdefault ]; then
			acpaths=
			for i in `find ${AUTOTOOLS_SCRIPT_PATH} -ignore_readdir_race -maxdepth 2 -name \*.m4|grep -v 'aclocal.m4'| \
				grep -v 'acinclude.m4' | sed -e 's,\(.*/\).*$,\1,'|sort -u`; do
				acpaths="$acpaths -I $i"
			done
		else
			acpaths="${acpaths}"
		fi
                acpaths="$acpaths -I ${ACLOCALDIR}"
                if [ -d ${STAGING_DATADIR_NATIVE}/aclocal ]; then
			acpaths="$acpaths ${ACLOCALEXTRAPATH}"
                fi
		AUTOV=`automake --version | sed -e '1{s/.* //;s/\.[0-9]\+$//};q'`
		automake --version
		echo "AUTOV is $AUTOV"
		if [ -d ${STAGING_DATADIR_NATIVE}/aclocal-$AUTOV ]; then
			ACLOCAL="$ACLOCAL --automake-acdir=${STAGING_DATADIR_NATIVE}/aclocal-$AUTOV"
		fi
		# autoreconf is too shy to overwrite aclocal.m4 if it doesn't look
		# like it was auto-generated.  Work around this by blowing it away
		# by hand, unless the package specifically asked not to run aclocal.
                if ! echo ${EXTRA_AUTORECONF_DEFINE} | grep -q "ACLOCAL"; then
			rm -f aclocal.m4
		fi
		if [ -e configure.in ]; then
			CONFIGURE_AC=configure.in
		else
			CONFIGURE_AC=configure.ac
		fi
                sed -i '/AC_CANONICAL_TARGET/atest -n $target_alias && test "$target_alias" = "$host_alias" && test "$program_prefix$program_suffix$program_transform_name" = "${target_alias}-NONEs,x,x," && program_prefix=NONE' ${CONFIGURE_AC}
		if grep -q "^[[:space:]]*AM_GLIB_GNU_GETTEXT" $CONFIGURE_AC; then
			if grep -q "sed.*POTFILES" $CONFIGURE_AC; then
				: do nothing -- we still have an old unmodified configure.ac
			else
				bbnote Executing glib-gettextize --force --copy
				echo "no" | glib-gettextize --force --copy
			fi
		elif [ "${BPN}" != "gettext" ] && grep -q "^[[:space:]]*AM_GNU_GETTEXT" $CONFIGURE_AC; then
			# We'd call gettextize here if it wasn't so broken...
			cp /usr/share/gettext/config.rpath ${AUTOTOOLS_AUXDIR}/
			if [ -d ${S}/po/ ]; then
				cp -f /usr/share/gettext/po/Makefile.in.in ${S}/po/
				if [ ! -e ${S}/po/remove-potcdate.sin ]; then
					cp /usr/share/gettext/po/remove-potcdate.sin ${S}/po/
				fi
			fi
			PRUNE_M4="$PRUNE_M4 gettext.m4 iconv.m4 lib-ld.m4 lib-link.m4 lib-prefix.m4 nls.m4 po.m4 progtest.m4"
		fi
		mkdir -p m4
		if grep -q "^[[:space:]]*[AI][CT]_PROG_INTLTOOL" $CONFIGURE_AC; then
			if ! echo "${DEPENDS}" | grep -q intltool-native; then
				bbwarn "Missing DEPENDS on intltool-native"
			fi
			PRUNE_M4="$PRUNE_M4 intltool.m4"
			bbnote Executing intltoolize --copy --force --automake
			intltoolize --copy --force --automake
		fi

		for i in $PRUNE_M4; do
			find ${S} -ignore_readdir_race -name $i -delete
		done

                tmp_site=`pwd`/tmp.site
                rm -f ${tmp_site}
                for f in $CONFIG_SITE
                do
                     bbnote Adding script ${f} to site file
                     cat $f >> ${tmp_site}
                done
                export CONFIG_SITE=${tmp_site}

                bbnote Executing ACLOCAL=\"$ACLOCAL\" ${EXTRA_AUTORECONF_DEFINE} autoreconf --verbose --install --force ${EXTRA_AUTORECONF} $acpaths
                ACLOCAL="$ACLOCAL" ${EXTRA_AUTORECONF_DEFINE} autoreconf -Wcross --verbose --install --force ${EXTRA_AUTORECONF} $acpaths || die "autoreconf execution failed."
                cp -f ${RECIPE_SYSROOT_NATIVE}/usr/share/gnu-config/config.guess .
                cp -f ${RECIPE_SYSROOT_NATIVE}/usr/share/gnu-config/config.sub .
		cd $olddir
	fi
        test ! -f ${S}/aclocal.m4 || sed -i "/MSGMERGE_FOR_MSGFMT_OPTION/{s|--for-msgfmt||g}" ${S}/aclocal.m4
        test ! -f ${S}/configure || sed -i "/MSGMERGE_FOR_MSGFMT_OPTION/{s|--for-msgfmt||g}" ${S}/configure
	if [ -e ${CONFIGURE_SCRIPT} ]; then
		oe_runconf
	else
		bbnote "nothing to configure"
	fi
}

autotools_do_compile() {
        for libtool_file in `find ${B} -ignore_readdir_race -name libtool`; do
            sed -i 's/macro_version=2.4.2/macro_version=2.4.6/g' $libtool_file
            sed -i 's/macro_revision=1.3337/macro_revision=2.4.6/g' $libtool_file
            sed -i 's/VERSION=2.4.2/VERSION=2.4.6/g' $libtool_file
            sed -i 's/package_revision=2.4.2/package_revision=2.4.6/g' $libtool_file
            sed -i 's/package_revision=1.3337/package_revision=2.4.6/g' $libtool_file
            if [ ${BUILD_SYS} != ${TARGET_SYS} ]; then
                sed -i 's|lt_sysroot=|lt_sysroot=${RECIPE_SYSROOT}|' $libtool_file
            fi
            sed -i '/fake/{ n; s/add_dir=-L$libdir/add_dir="-L$lt_sysroot$libdir"/; }' $libtool_file
            sed -i '/fake/{ n; s/add_dir="-L$libdir"/add_dir="-L$lt_sysroot$libdir"/; }' $libtool_file
        done
        oe_runmake
}

autotools_do_install() {
	oe_runmake 'DESTDIR=${D}' install
	# Info dir listing isn't interesting at this point so remove it if it exists.
	if [ -e "${D}${infodir}/dir" ]; then
		rm -f ${D}${infodir}/dir
	fi
}

inherit siteconfig

EXPORT_FUNCTIONS do_configure do_compile do_install

B = "${WORKDIR}/build"
