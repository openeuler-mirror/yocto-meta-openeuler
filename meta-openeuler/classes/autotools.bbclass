OPENEULER_AUTOTOOLS_BBCLASS = "${@['${COREBASE}/meta/classes/autotools.bbclass', './openeuler_autotools.bbclass']['${OPENEULER_PREBUILD_TOOLS_ENABLE}' == 'yes']}"

require ${OPENEULER_AUTOTOOLS_BBCLASS}

# used for exporting tasks in openeuler_autotools.bbclass
EXPORT_FUNCTIONS do_configure do_compile do_install
