def get_external_libc_version(d):
    if (d.getVar('TCMODE', True).startswith('external') and
            d.getVar('EXTERNAL_TOOLCHAIN', True)):
        cc = os.path.join(d.getVar('EXTERNAL_TOOLCHAIN_SYSROOT', True), "usr/bin/ldd --version")
        # ldd is a script, ldd --version will output "ldd (xxx yyy) zzz", zzz is version
        # for aws use ')'as delimiter, use '{$1=$1;print}' to strip space, then get zzz
        cmd = "%s | head -n1 | awk -F\) '{print $2}' | awk '{$1=$1;print}' " % cc
        import subprocess
        p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
        stdout, stderr = p.communicate()
        version = str(stdout, 'utf-8').strip()
        return version

    return 'UNKNOWN'

PV:tcmode-external := "${@get_external_libc_version(d)}"
