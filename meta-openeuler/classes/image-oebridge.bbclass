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
    import fnmatch

    def check_oe_repo_rpm_map(root_dir, prefix):
        # the oe'pkg to make db must in pre-install pkg pool(oee's rootfs rpm repo)
        for root, dirs, files in os.walk(root_dir):
            for filename in fnmatch.filter(files, f'{prefix}*rpm'):
                return True
        return False

    def make_db(db_dir, rpms_dir, root_tmp):
        installed_set = set()
        bad_map_set = set()
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
                    if pkg_split[1] in bad_map_set:
                        continue
                    if not check_oe_repo_rpm_map(root_tmp + "/../oe-rootfs-repo/rpm/", pkg_split[1]):
                        bad_map_set.add(pkg_split[1])
                        continue
                    for rpm_pkg in fi[2]:
                        # avoid duplicate and accelerate our db build.
                        if rpm_pkg in installed_set:
                            continue
                        if not rpm_pkg.endswith(".rpm"):
                            continue
                        print(f"make rpm db: {rpm_pkg}")
                        res = subprocess.run(f"rpm -ivh --dbpath {db_dir} --nosignature \
                            --root {root_tmp} --nodeps --justdb --ignorearch {rpm_pkg} --force",
                            shell=True,
                            stderr=subprocess.PIPE,
                            cwd=fi[0],
                            text=True)
                        if res.returncode != 0:
                            bb.fatal(res.stderr)
                        installed_set.add(rpm_pkg)

    # make rpm db
    rpms_cache_dir = f"{d.getVar('TOPDIR')}/cache/rpms"+ \
                    "/"+d.getVar('SERVER_VERSION')+ \
                    "/oe"+ \
                    "/"+d.getVar('TUNE_ARCH')
    db_cache_dir = "/var/lib/rpm"
    rootfs_db_files = d.getVar('IMAGE_ROOTFS') + "/var/lib/rpm/*" 
    subprocess.run(f"rm -rf {rootfs_db_files}",shell=True)
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

    def run_cmd_with_cwd(cmd, cwd):
        res = subprocess.run(cmd,
                        shell=True,
                        stderr=subprocess.PIPE,
                        cwd=cwd,
                        text=True)
        if res.returncode != 0:
                bb.fatal(res.stderr)

    cache_dir = f"{d.getVar('TOPDIR')}/cache/install_pkgs"
    force_list = []
    real_list = []
    with open(f"{d.getVar('TOPDIR')}/cache/INSTALL_PKG_LIST", 'r', encoding='utf-8') as f:
        pkg_lists = f.read().replace("\n"," ")
        for pkg in pkg_lists.split():
            if pkg == "":
                continue
            if ":force" in pkg:
                pkg = pkg.split(":")[0]
                force_list.append(pkg)
            if ":real" in pkg:
                pkg = pkg.split(":")[0]
                real_list.append(pkg)
                continue
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
    
    ros_repo_path = f"{d.getVar('THISDIR')}/../../recipes-devtools/dnf/files/openEulerROS.repo"
    if os.path.exists(ros_repo_path):
        subprocess.run(f"cp {ros_repo_path} {repo_dir}",
            shell=True,
            cwd=repo_dir)
        subprocess.run(f"sed -i 's/OPENEULER_VER/{d.getVar('SERVER_VERSION')}/g' openEulerROS.repo",
            shell=True,
            cwd=repo_dir)
    else:
        bb.error("openEuler.repo not found")

    # do some prepare action
    if len(real_list) > 0:
        run_cmd_with_cwd(f"PSEUDO_UNLOAD=1 cp -rfP rootfs temp/", d.getVar("WORKDIR"))
        run_cmd_with_cwd(f"getfacl -R rootfs > temp/rootfs_permission", d.getVar("WORKDIR"))
        run_cmd_with_cwd(f"find rootfs -type l -printf '%u:%g %p\n' > temp/rootfs_softlink", d.getVar("WORKDIR"))
        run_cmd_with_cwd(f"PSEUDO_UNLOAD=1 sudo setfacl --restore=rootfs_permission", d.getVar("WORKDIR")+"/temp")
        run_cmd_with_cwd(f"cat rootfs_softlink | while read -r o p;do PSEUDO_UNLOAD=1 sudo chown -h \"$o\" \"$p\"; done", d.getVar("WORKDIR")+"/temp")
        real_list_str = " ".join(real_list)
        run_cmd_with_cwd(f"PSEUDO_UNLOAD=1 sudo chroot temp/rootfs dnf install \
        {real_list_str} -y --nogpgcheck --setopt=sslverify=0 --nobest", d.getVar("WORKDIR"))
        run_cmd_with_cwd(f"PSEUDO_UNLOAD=1 sudo getfacl -R rootfs > ../rootfs_permission", d.getVar("WORKDIR")+"/temp")
        run_cmd_with_cwd(f"PSEUDO_UNLOAD=1 sudo find rootfs -type l -printf '%u:%g %p\n' > ../rootfs_softlink", d.getVar("WORKDIR")+"/temp")
        res = subprocess.run("stat -c '%u:%g' temp",
                        shell=True,
                        stderr=subprocess.PIPE,
                        stdout=subprocess.PIPE,
                        cwd=d.getVar("WORKDIR"),
                        text=True)
        if res.returncode != 0:
            bb.fatal(res.stderr)
        ugid = res.stdout.strip()
        run_cmd_with_cwd(f"PSEUDO_UNLOAD=1 sudo chroot temp/rootfs chown -R {ugid} /", d.getVar("WORKDIR"))
        run_cmd_with_cwd(f"PSEUDO_UNLOAD=1 sudo chroot temp/rootfs chmod -R 777 /", d.getVar("WORKDIR"))
        run_cmd_with_cwd(f"PSEUDO_UNLOAD=1 sudo rm -f temp/rootfs/root/.bash_history", d.getVar("WORKDIR"))
        run_cmd_with_cwd(f"rm -rf ./rootfs", d.getVar("WORKDIR"))
        run_cmd_with_cwd(f"cp -rfP temp/rootfs ./", d.getVar("WORKDIR"))
        run_cmd_with_cwd(f"setfacl --restore=rootfs_permission", d.getVar("WORKDIR"))
        run_cmd_with_cwd(f"cat rootfs_softlink | while read -r o p;do chown -h \"$o\" \"$p\"; done", d.getVar("WORKDIR"))
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
}

fakeroot do_custom_install_prepare() {
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
    #  avoid chkconfig conflict with initscripts by rc5.d (physical vs softlink)
    for level in {0..6}; do
        if [ -d "${IMAGE_ROOTFS}/etc/rc${level}.d" ]; then
            mv "${IMAGE_ROOTFS}/etc/rc${level}.d" "${IMAGE_ROOTFS}/etc/rc${level}.d-yocto-tmp"
        fi
    done
    
    # for dnf install, then shoud delete it
    if [ ! -d "${IMAGE_ROOTFS}/var/volatile/log" ]; then
        mkdir -p ${IMAGE_ROOTFS}/var/volatile/log
    fi
    if [ ! -d "${IMAGE_ROOTFS}/var/volatile/tmp" ]; then
        mkdir -p ${IMAGE_ROOTFS}/var/volatile/tmp
    fi

    # backup ${IMAGE_ROOTFS}/etc/resolv.conf
    if [ -f "${IMAGE_ROOTFS}/etc/resolv.conf" ] || [ -L "${IMAGE_ROOTFS}/etc/resolv.conf" ]; then
        mv ${IMAGE_ROOTFS}/etc/resolv.conf ${IMAGE_ROOTFS}/etc/resolv.conf.bak
    fi
    cp -f /etc/resolv.conf ${IMAGE_ROOTFS}/etc/resolv.conf
}

fakeroot do_custom_install_complete() {
    # workaround for pkg chkconfig conflict, restore /etc/init.d-yocto-tmp to /etc/init.d
    targetdir=$(readlink -f "${IMAGE_ROOTFS}/etc/init.d")
    if [ -d "$targetdir" ]; then
       # path or soft link path exist
       mv ${IMAGE_ROOTFS}/etc/init.d-yocto-tmp/* ${IMAGE_ROOTFS}/etc/init.d 2>/dev/null || true
       rm -rf ${IMAGE_ROOTFS}/etc/init.d-yocto-tmp
    else
       # path or soft link path not exist
       mv ${IMAGE_ROOTFS}/etc/init.d-yocto-tmp ${IMAGE_ROOTFS}/etc/init.d 2>/dev/null || true
    fi

    for level in {0..6}; do
        targetdir=$(readlink -f "${IMAGE_ROOTFS}/etc/rc${level}.d")
        if [ -d "$targetdir" ]; then
            # path or soft link path exist
            mv ${IMAGE_ROOTFS}/etc/rc${level}.d-yocto-tmp/* ${IMAGE_ROOTFS}/etc/rc${level}.d 2>/dev/null || true
            rm -rf ${IMAGE_ROOTFS}/etc/rc${level}.d-yocto-tmp
        else
            # path or soft link path not exist
            mv ${IMAGE_ROOTFS}/etc/rc${level}.d-yocto-tmp ${IMAGE_ROOTFS}/etc/rc${level}.d 2>/dev/null || true
        fi
    done

    # delete log
    if [ -d "${IMAGE_ROOTFS}/var/volatile/log" ]; then
        rm -rf ${IMAGE_ROOTFS}/var/volatile/log
    fi
    if [ -d "${IMAGE_ROOTFS}/var/volatile/tmp" ]; then
        rm -rf ${IMAGE_ROOTFS}/var/volatile/tmp
    fi

    # delete ${IMAGE_ROOTFS}/etc/resolv.conf
    if [ -f "${IMAGE_ROOTFS}/etc/resolv.conf" ]; then
        rm ${IMAGE_ROOTFS}/etc/resolv.conf
    fi
    # restore ${IMAGE_ROOTFS}/etc/resolv.conf.bak，to resolv.conf
    if [ -f "${IMAGE_ROOTFS}/etc/resolv.conf.bak" ] || [ -L "${IMAGE_ROOTFS}/etc/resolv.conf.bak" ]; then
        mv ${IMAGE_ROOTFS}/etc/resolv.conf.bak ${IMAGE_ROOTFS}/etc/resolv.conf
    fi
}

do_oebridge_clean() {
    sudo rm -rf ${WORKDIR}/temp/rootfs
}


# do_rootfs -> do_make_rootfs_db -> do_custom_install_prepare -> do_dnf_install_pkgs -> do_custom_install_complete -> do_run_post_action -> do_image
addtask do_make_rootfs_db after do_rootfs before do_dnf_install_pkgs
addtask do_dnf_install_pkgs before do_run_post_action
addtask do_run_post_action before do_image
addtask do_custom_install_prepare before do_dnf_install_pkgs after do_make_rootfs_db
addtask do_custom_install_complete after do_dnf_install_pkgs before do_run_post_action
addtask do_oebridge_clean before do_clean
