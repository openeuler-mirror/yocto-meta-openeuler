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


fakeroot python do_make_rootfs_db(){
    import os
    import shutil
    import subprocess

    def make_db(db_dir, rpms_dir, root_tmp):
        with open(f"{d.getVar('TOPDIR')}/cache/ASSUME_PROVIDE_PKGS", 'r', encoding='utf-8') as f:
            pkg_data = f.readlines()
            for pkg in pkg_data:
                pkg = pkg.strip("\n").strip(" ")
                pkg_split = pkg.split(":")
                # < 3 mean that there is no openeuler server pkgs，an example is pkg:pkg-sub:server pkg
                if len(pkg_split)<3:
                    continue
                for fi in os.walk(os.path.join(rpms_dir, pkg_split[0])):
                    if len(fi[2])==0:
                        continue
                    for rpm_pkg in fi[2]:
                        if not rpm_pkg.endswith(".rpm"):
                            continue
                        res = subprocess.run(f"rpm -ivh --dbpath {db_dir} --nosignature \
                            --root {root_tmp} --nodeps --justdb --ignorearch {rpm_pkg} --force",
                            shell=True,
                            stderr=subprocess.PIPE,
                            cwd=fi[0],
                            text=True)
                        if res.returncode != 0:
                            bb.fatal(res.stderr)

    # make rpm db
    rpms_cache_dir = f"{d.getVar('TOPDIR')}/cache/rpms"+ \
                    "/"+d.getVar('SERVER_VERSION')+ \
                    "/oe"+ \
                    "/"+d.getVar('TUNE_ARCH')
    db_cache_dir = "/var/lib/rpm"
    subprocess.run(f"rm -rf {os.path.join(d.getVar('IMAGE_ROOTFS'), db_cache_dir)}",shell=True)
    make_db(db_dir=db_cache_dir, rpms_dir=rpms_cache_dir, root_tmp=d.getVar("IMAGE_ROOTFS"))
}

fakeroot python do_dnf_install_pkgs(){
    import os
    import shutil
    import subprocess
    import dnf
    import dnf.base
    import dnf.conf

    DEFAULT_REPO_LIST = get_default_repo_list(d)

    def init_base_extend(rootfs, cache_dir):
        dnf.rpm.transaction.rpm.addMacro('_dbpath', '/var/lib/rpm')
        base = dnf.Base()
        base.conf.substitutions['releasever'] = ''
        base.repos.all().disable()

        base.conf.substitutions['arch'] = d.getVar('TUNE_ARCH')
        base.conf.install_weak_deps = False
        base.conf.clean_requirements_on_remove = False
        base.conf.ignorearch = True
        base.conf.sslverify = False

        base.conf.cachedir = cache_dir
        base.conf.config_file_path = cache_dir
        base.conf.persistdir = cache_dir
        base.conf.installroot = os.path.abspath(rootfs)

        for repo_info in DEFAULT_REPO_LIST:
            repo = base.repos.add_new_repo(repo_info["name"], base.conf, baseurl=[repo_info["url"]])
            repo.enable()

        dnf.rpm.transaction.rpm.addMacro('_dbpath', '/var/lib/rpm')
        # load remote data
        base.fill_sack(load_system_repo=True, load_available_repos=True)
        return base

    def install_pkg(rootfs, cache_dir, package_name):
        base = init_base_extend(rootfs, cache_dir)
        base.install(package_name)

        try:
            base.resolve()
        except dnf.exceptions.DepsolveError as e:
            raise RuntimeError(f"Dependency resolution failed: {str(e)}")
        base.download_packages(base.transaction.install_set)
        base.do_transaction()

    cache_dir = f"{d.getVar('TOPDIR')}/cache/install_pkgs"
    force_list = []
    with open(f"{d.getVar('TOPDIR')}/cache/INSTALL_PKG_LIST", 'r', encoding='utf-8') as f:
        pkg_lists = f.read().replace("\n"," ")
        for pkg in pkg_lists.split():
            if pkg == "":
                continue
            if ":force" in pkg:
                pkg = pkg.split(":")[0]
                force_list.append(pkg)
            install_pkg(d.getVar('IMAGE_ROOTFS'), cache_dir, pkg)

    base = init_base_common(DEFAULT_REPO_LIST)
    # download server rpm
    rpms_cache_dir = f"{d.getVar('TOPDIR')}/cache/rpms"
    download_pre_dir = rpms_cache_dir+ \
                "/"+d.getVar('SERVER_VERSION')+ \
                "/oe"+ \
                "/"+d.getVar('TUNE_ARCH')
    for pkg in force_list:
        bb.plain(f"reinstall {pkg} with:")
        pkg_dir = download_pre_dir+"/"+pkg
        os.makedirs(name=pkg_dir, exist_ok=True)
        rpm_info = get_package_details(base, pkg)
        if rpm_info is None:
            bb.plain(f"reinstall {pkg} failed: target not found.")
            continue
        if not os.path.exists(os.path.join(pkg_dir, rpm_info['Package'])):
            res = subprocess.run(f"wget {rpm_info['Url']}",
                shell=True,
                stderr=subprocess.PIPE,
                cwd=pkg_dir,
                text=True)
            if res.returncode != 0:
                bb.fatal(res.stderr)
                return
        bb.plain(rpm_info['Package'])
        res = subprocess.run(f"rpm -ivh --dbpath /var/lib/rpm --nosignature \
            --root {d.getVar('IMAGE_ROOTFS')} --nodeps --ignorearch {rpm_info['Package']} --force",
                    shell=True,
                    stderr=subprocess.PIPE,
                    cwd=pkg_dir,
                    text=True)
        if res.returncode != 0:
            bb.fatal(res.stderr)
}


python do_run_post_action(){
    import os
    import subprocess
    import bb.utils
    # make oe source pkgs dir compatible
    ln_list = ["/bin/bash:usr/bin/bash",
                "/bin/pidof:usr/bin/pidof",
                "/sbin/restorecon:usr/sbin/restorecon",
                "/bin/sh:usr/bin/sh"]

    if "systemd" in d.getVar("DISTRO_FEATURES"):
        ln_list.extend([
        "/sbin/udevadm:usr/bin/",
        "/bin/systemd-hwdb:usr/bin/",
        "/bin/systemctl:usr/bin/",
        "/usr/bin/update-alternatives:usr/sbin/",
        "/bin/systemd-tmpfiles:usr/bin/"
    ])

    for ln_line in ln_list:
        ln_split = ln_line.split(":")
        if os.path.exists(os.path.join(d.getVar("IMAGE_ROOTFS"), ln_split[0])):
            subprocess.run(f"ln -s {ln_split[0]} {ln_split[1]}",shell=True,cwd=d.getVar("IMAGE_ROOTFS"),text=True)

    repo_dir = d.getVar('IMAGE_ROOTFS') + "/etc/yum.repos.d"
    os.makedirs(repo_dir, exist_ok=True)

    openeuler_repo_path = f"{d.getVar('THISDIR')}/../../recipes-devtools/dnf/files/openEuler.repo"
    if os.path.exists(openeuler_repo_path):
        subprocess.run(f"cp {openeuler_repo_path} {repo_dir}",
            shell=True,
            cwd=repo_dir)
        subprocess.run(f"sed -i 's/OPENEULER_VER/{d.getVar('SERVER_VERSION')}/g' openEuler.repo",
            shell=True,
            cwd=repo_dir)
    else:
        bb.error("openEuler.repo not found")
}

do_custom_install_prepare() {
    # This is a workaround for the server environment where the chkconfig package (a low-level foundational 
    # software component) is provided. This package creates a symbolic link /etc/init.d, which conflicts with 
    # any existing physical /etc/init.d directory, preventing the installation of the chkconfig package.
    # In Yocto, physical /etc/init.d directories are commonly generated by many recipes. 
    # To address this compatibility issue, the following adaptation is implemented:
    #  a. If a physical /etc/init.d directory exists, it is renamed and backed up.
    #  b. The chkconfig package is then installed.
    #  c. After installation, the contents of the backed-up /etc/init.d directory are restored to their original location.
    #  This ensures compatibility while allowing both the chkconfig package and Yocto-generated /etc/init.d files to coexist.

    #  here, we backup /etc/init.d to /etc/init.d-yocto-tmp:
    if [ -d "${IMAGE_ROOTFS}/etc/init.d" ]; then
        mv ${IMAGE_ROOTFS}/etc/init.d ${IMAGE_ROOTFS}/etc/init.d-yocto-tmp
    fi
}

do_custom_install_complete() {
    # workaround for pkg chkconfig conflict, restore /etc/init.d-yocto-tmp to /etc/init.d
    targetdir=$(readlink -f "${IMAGE_ROOTFS}/etc/init.d")
    if [ -d "$targetdir" ]; then
       # path or soft link path exist
       mv ${IMAGE_ROOTFS}/etc/init.d-yocto-tmp/* ${IMAGE_ROOTFS}/etc/init.d
       rm -r ${IMAGE_ROOTFS}/etc/init.d-yocto-tmp
    else
       # path or soft link path not exist
       mv ${IMAGE_ROOTFS}/etc/init.d-yocto-tmp ${IMAGE_ROOTFS}/etc/init.d
    fi
}

do_dnf_install_pkgs:prepend() {
    bb.build.exec_func('do_custom_install_prepare', d)
}

do_dnf_install_pkgs:append() {
    bb.build.exec_func('do_custom_install_complete', d)
}

# do_rootfs -> do_make_rootfs_db -> do_dnf_install_pkgs -> do_run_post_action -> do_image
addtask do_make_rootfs_db after do_rootfs before do_dnf_install_pkgs
addtask do_dnf_install_pkgs before do_run_post_action
addtask do_run_post_action before do_image
