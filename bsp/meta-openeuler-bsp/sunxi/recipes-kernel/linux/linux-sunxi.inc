# add recipes-kernel path to find patch and defconfig
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

SRC_URI:remove = " \
    file://kernel-5.10 \
    file://patches/${ARCH}/0001-arm64-add-zImage-support-for-arm64.patch \
"

## basic information
OPENEULER_REPO_NAME = "allwinner-kernel"
# download src-openeuler/kernel repo for patches

SRC_URI:append = " \
    file://allwinner-kernel \
"

S = "${WORKDIR}/allwinner-kernel"

INHIBIT_PACKAGE_STRIP = "1"

DEPENDS += " dos2unix-native "

OPENEULER_KERNEL_CONFIG = "file://config/${MACHINE}/defconfig"

# set env in do_kernel_configme
do_kernel_configme:prepend(){
    export BSP_TOP="${STAGING_KERNEL_DIR}/bsp/"
}

python do_kernel_configcheck() {
    import re, string, sys, subprocess

    s = d.getVar('S')

    # if KMETA isn't set globally by a recipe using this routine, use kgit to
    # locate or create the meta directory. Otherwise, kconf_check is not
    # passed a valid meta-series for processing
    kmeta = d.getVar("KMETA")
    if not kmeta or not os.path.exists('{}/{}'.format(s,kmeta)):
        kmeta = subprocess.check_output(['kgit', '--meta'], cwd=d.getVar('S')).decode('utf-8').rstrip()

    env = os.environ.copy()
    env['PATH'] = "%s:%s%s" % (d.getVar('PATH'), s, "/scripts/util/")
    env['LD'] = d.getVar('KERNEL_LD')
    env['CC'] = d.getVar('KERNEL_CC')
    env['ARCH'] = d.getVar('ARCH')
    env['srctree'] = s

    #------define some missing Flags environ------#
    missing_env = ["KERNEL_SRC", "LOADADDR", "LICHEE_BSP_DIR", "BSP_TOP", "LICHEE_OUT_DIR", "LICHEE_IC", "LICHEE_KERN_DIR", "LICHEE_PLATFORM", "LICHEE_MOD_DIR"]
    for missing_env_parameter in missing_env:
        env[missing_env_parameter] = d.getVar(missing_env_parameter)
    env['VERSION'] = '5'
    env['PATCHLEVEL'] = '10'
    #--------------------end----------------------#

    try:
        configs = subprocess.check_output(['scc', '--configs', '-o', s + '/.kernel-meta'], env=env).decode('utf-8')
    except subprocess.CalledProcessError as e:
        bb.fatal( "Cannot gather config fragments for audit: %s" % e.output.decode("utf-8") )

    config_check_visibility = int(d.getVar("KCONF_AUDIT_LEVEL") or 0)
    bsp_check_visibility = int(d.getVar("KCONF_BSP_AUDIT_LEVEL") or 0)
    kmeta_audit_werror = d.getVar("KMETA_AUDIT_WERROR") or ""
    warnings_detected = False

    # if config check visibility is "1", that's the lowest level of audit. So
    # we add the --classify option to the run, since classification will
    # streamline the output to only report options that could be boot issues,
    # or are otherwise required for proper operation.
    extra_params = ""
    if config_check_visibility == 1:
       extra_params = "--classify"

    # category #1: mismatches
    try:
        analysis = subprocess.check_output(['symbol_why.py', '--dotconfig',  '{}'.format( d.getVar('B') + '/.config' ), '--mismatches', extra_params], cwd=s, env=env ).decode('utf-8')
    except subprocess.CalledProcessError as e:
        bb.fatal( "config analysis failed when running '%s': %s" % (" ".join(e.cmd), e.output.decode('utf-8')))

    if analysis:
        outfile = "{}/{}/cfg/mismatch.txt".format( s, kmeta )
        if os.path.isfile(outfile):
           os.remove(outfile)
        with open(outfile, 'w+') as f:
            f.write( analysis )

        if config_check_visibility and os.stat(outfile).st_size > 0:
            with open (outfile, "r") as myfile:
                results = myfile.read()
                bb.warn( "[kernel config]: specified values did not make it into the kernel's final configuration:\n\n%s" % results)
                warnings_detected = True

    # category #2: invalid fragment elements
    extra_params = ""
    if bsp_check_visibility > 1:
        extra_params = "--strict"
    try:
        analysis = subprocess.check_output(['symbol_why.py', '--dotconfig',  '{}'.format( d.getVar('B') + '/.config' ), '--invalid', extra_params], cwd=s, env=env ).decode('utf-8')
    except subprocess.CalledProcessError as e:
        bb.fatal( "config analysis failed when running '%s': %s" % (" ".join(e.cmd), e.output.decode('utf-8')))

    if analysis:
        outfile = "{}/{}/cfg/invalid.txt".format(s,kmeta)
        if os.path.isfile(outfile):
           os.remove(outfile)
        with open(outfile, 'w+') as f:
            f.write( analysis )

        if bsp_check_visibility and os.stat(outfile).st_size > 0:
            with open (outfile, "r") as myfile:
                results = myfile.read()
                bb.warn( "[kernel config]: This BSP contains fragments with warnings:\n\n%s" % results)
                warnings_detected = True

    # category #3: redefined options (this is pretty verbose and is debug only)
    try:
        analysis = subprocess.check_output(['symbol_why.py', '--dotconfig',  '{}'.format( d.getVar('B') + '/.config' ), '--sanity'], cwd=s, env=env ).decode('utf-8')
    except subprocess.CalledProcessError as e:
        bb.fatal( "config analysis failed when running '%s': %s" % (" ".join(e.cmd), e.output.decode('utf-8')))

    if analysis:
        outfile = "{}/{}/cfg/redefinition.txt".format(s,kmeta)
        if os.path.isfile(outfile):
           os.remove(outfile)
        with open(outfile, 'w+') as f:
            f.write( analysis )

        # if the audit level is greater than two, we report if a fragment has overriden
        # a value from a base fragment. This is really only used for new kernel introduction
        if bsp_check_visibility > 2 and os.stat(outfile).st_size > 0:
            with open (outfile, "r") as myfile:
                results = myfile.read()
                bb.warn( "[kernel config]: This BSP has configuration options defined in more than one config, with differing values:\n\n%s" % results)
                warnings_detected = True

    if warnings_detected and kmeta_audit_werror:
        bb.fatal( "configuration warnings detected, werror is set, promoting to fatal" )
}
