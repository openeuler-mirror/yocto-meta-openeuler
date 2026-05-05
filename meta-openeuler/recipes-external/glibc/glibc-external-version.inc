def get_external_libc_version(d):
    if (d.getVar('TCMODE', True).startswith('external') and
            d.getVar('EXTERNAL_TOOLCHAIN', True)):
        # ldd is a shell script; "ldd --version" outputs "ldd (GNU libc) X.Y.Z"
        # Separate the binary path from the argument to avoid embedding --version
        # inside the file path passed to os.path.join.
        ldd = os.path.join(d.getVar('EXTERNAL_TOOLCHAIN_SYSROOT', True), "usr/bin/ldd")
        # use ')' as field delimiter to get the part after ')', then strip spaces
        cmd = "%s --version | head -n1 | awk -F') ' '{print $2}' | awk '{$1=$1;print}'" % ldd
        import subprocess
        try:
            p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE,
                                 stderr=subprocess.DEVNULL)
            stdout, _ = p.communicate()
            version = stdout.decode('utf-8', errors='replace').strip()
            if version:
                return version
        except Exception as e:
            bb.warn('glibc-external-version: failed to detect glibc version: %s' % e)

    return 'UNKNOWN'

PV:tcmode-external := "${@get_external_libc_version(d)}"
