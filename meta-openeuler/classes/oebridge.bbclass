python(){
    import os
    import subprocess

    repo_name = d.getVar('OPENEULER_LOCAL_NAME')

    src_dir = d.getVar('OPENEULER_SP_DIR')
    repo_dir = os.path.join(src_dir, repo_name)
    spec_path = os.path.join(repo_dir, repo_name+".spec")
    spec_name = repo_name+".spec"
    server_rpms = ""
    # note: if set ASSUME_PROVIDE_PKGS mean to all PACKAGES is ASSUME_PROVIDE_PKGS value,
    # but if set sub package, the sub pacakge will be it's own value
    if d.getVar("ASSUME_PROVIDE_PKGS") is not None and d.getVar("ASSUME_PROVIDE_PKGS") != "":
        server_rpms = d.getVar("ASSUME_PROVIDE_PKGS")
    else:
        # get pkgnames from spec
        if os.path.exists(spec_path):
            # this feature shoud use with oee nativesdk
            res = subprocess.run(f"rpmspec -q {spec_name} \
                --rcfile=/opt/buildtools/nativesdk/sysroots/x86_64-openeulersdk-linux/usr/lib/rpm/rpmrc \
                --macros=/lib/rpm/macros:/lib/rpm/openEuler/macros \
                --define='_sourcedir ./' | sed 's/-[0-9].*//'", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, cwd=repo_dir)
            if res.returncode != 0:
                bb.error(res.stderr)
                return
            server_rpms = res.stdout.replace("\n"," ")

    for sub_name in d.getVar("PACKAGES").split(" "):
        sub_name = sub_name.strip()
        if sub_name == "":
            continue
        if d.getVar(f"ASSUME_PROVIDE_PKGS:{sub_name}") is None:
            d.setVar(f"ASSUME_PROVIDE_PKGS:{sub_name}", server_rpms)
}

addtask do_download_oepkg before do_package_write_rpm after do_package_qa

inherit oebridge-common

def get_package_details(base, package_name):
    query = base.sack.query().available().filter(name=package_name)
    if not query:
        print(f"Package '{package_name}' not found in the repository.")
        return
    pkg = query[0]
    return {
        "Package": os.path.basename(pkg.remote_location()),
        "Url": pkg.remote_location(),
        "Checksum": pkg.chksum[1].hex()
    }

python do_download_oepkg(){
    import os
    import subprocess

    DEFAULT_REPO_LIST = get_default_repo_list(d)

    rpms_cache_dir = f"{d.getVar('TOPDIR')}/cache/rpms"
    os.makedirs(name=rpms_cache_dir, exist_ok=True)
    base = init_base_common(DEFAULT_REPO_LIST)
    for sub_name in d.getVar("PACKAGES").split(" "):
        sub_name = sub_name.strip()
        if sub_name == "":
            continue
        # bb.plain(d.getVar(f"ASSUME_PROVIDE_PKGS:{sub_name}"))
        if d.getVar(f"ASSUME_PROVIDE_PKGS:{sub_name}") is None:
            continue
        prefix_name = d.getVar("PN")+":"+sub_name
        # remove duplicates
        subprocess.run(f"test -f ASSUME_PROVIDE_PKGS && sed -i '/^{prefix_name}:/d' ASSUME_PROVIDE_PKGS",
            shell=True,
            cwd=f"{d.getVar('TOPDIR')}/cache",
            text=True)

        # write server rpm info to ASSUME_PROVIDE_PKGS file
        server_rpms = " ".join(d.getVar(f"ASSUME_PROVIDE_PKGS:{sub_name}").replace("\n", " ").split())
        with open(f"{d.getVar('TOPDIR')}/cache/ASSUME_PROVIDE_PKGS", 'a', encoding='utf-8') as f:
            f.write(prefix_name+":"+server_rpms+"\n")

        # download server rpm
        download_pre_dir = rpms_cache_dir+ \
                    "/"+d.getVar('SERVER_VERSION')+ \
                    "/oe"+ \
                    "/"+d.getVar('TUNE_ARCH')
        pn_dir = download_pre_dir+"/"+d.getVar("PN")
        os.makedirs(name=pn_dir, exist_ok=True)
        for server_rpm in server_rpms.split(" "):
            rpm_info = get_package_details(base, server_rpm)
            if rpm_info is None:
                continue
            if os.path.exists(os.path.join(pn_dir, rpm_info['Package'])):
                continue
            res = subprocess.run(f"wget {rpm_info['Url']}",
                shell=True,
                stderr=subprocess.PIPE,
                cwd=pn_dir,
                text=True)
            if res.returncode != 0:
                bb.fatal(res.stderr)
                return
}
do_download_oepkg[network] = "1"
