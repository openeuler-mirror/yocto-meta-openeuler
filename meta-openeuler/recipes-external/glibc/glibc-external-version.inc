def get_external_libc_version(d):
    if (d.getVar('TCMODE', True).startswith('external') and
            d.getVar('EXTERNAL_TOOLCHAIN', True)):
        cc = os.path.join(d.getVar('EXTERNAL_TOOLCHAIN_BIN', True), d.getVar('EXTERNAL_CC', True))
        cmd = "strings %s | grep '^GLIBC_' | awk -F_ '{print $2}' | sort -V | tail -n1" % cc
        import subprocess
        p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
        stdout, stderr = p.communicate()
        version = str(stdout, 'utf-8').strip()
        return version

    return 'UNKNOWN'

PV_tcmode-external := "${@get_external_libc_version(d)}"
