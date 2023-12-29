# add recipes-kernel path to find patch and defconfig
FILESEXTRAPATHS_append := "${THISDIR}/files/:"

SRC_URI_remove = " \
    file://kernel-5.10 \
    file://patches/${ARCH}/0001-arm64-add-zImage-support-for-arm64.patch \
    "
python do_fetch() {
    # download src-openeuler/kernel repo for patches
    d.setVar("OPENEULER_REPO_NAME", "kernel")
    d.setVar("OPENEULER_LOCAL_NAME", 'src-allwinner-kernel')
    bb.build.exec_func("do_openeuler_fetch", d)

    # download openeuler/kernel-5.10 repo for linux kernel src files
    d.setVar("OPENEULER_REPO_NAME", "allwinner-kernel")
    d.setVar("OPENEULER_LOCAL_NAME", 'allwinner-kernel')
    bb.build.exec_func("do_openeuler_fetch", d)
}

SRC_URI_append = " \
    file://allwinner-kernel \
    file://config/${MACHINE}/${MACHINE}_defconfig \
"

S = "${WORKDIR}/allwinner-kernel"

INHIBIT_PACKAGE_STRIP = "1"

DEPENDS += " dos2unix-native "

OPENEULER_KERNEL_CONFIG = "../config/${MACHINE}/${MACHINE}_defconfig"

# set env in do_kernel_configme
do_kernel_configme_prepend(){
    export BSP_TOP="${STAGING_KERNEL_DIR}/bsp/"
}

python do_kernel_configcheck() {
    import re, string, sys, subprocess, os

    s = d.getVar('S')

    kmeta = d.getVar("KMETA")
    if not kmeta or not os.path.exists('{}/{}'.format(s,kmeta)):
        kmeta = subprocess.check_output(['kgit', '--meta'], cwd=d.getVar('S')).decode('utf-8').rstrip()

    env = os.environ.copy()
    env['PATH'] = "%s:%s%s" % (d.getVar('PATH'), s, "/scripts/util/")
    env['LD'] = d.getVar('KERNEL_LD')
    env['CC'] = d.getVar('KERNEL_CC')
    env['ARCH'] = d.getVar('ARCH')
    env['srctree'] = s
    
    # define some missing Flags environ
    env['KERNEL_SRC'] = d.getVar('KERNEL_SRC')
    env['LOADADDR'] = d.getVar('LOADADDR')
    env['LICHEE_BSP_DIR'] = d.getVar('LICHEE_BSP_DIR')
    env['BSP_TOP'] = d.getVar('BSP_TOP')
    env['LICHEE_OUT_DIR'] = d.getVar('LICHEE_OUT_DIR')
    env['LICHEE_IC'] = d.getVar('LICHEE_IC')
    env['LICHEE_KERN_DIR'] = d.getVar('LICHEE_KERN_DIR')
    env['LICHEE_PLATFORM'] = d.getVar('LICHEE_PLATFORM')
    env['LICHEE_MOD_DIR'] = d.getVar('LICHEE_MOD_DIR')
    env['VERSION'] = '5'
    env['PATCHLEVEL'] = '10'

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
