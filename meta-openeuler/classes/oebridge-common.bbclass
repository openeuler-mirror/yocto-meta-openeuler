def init_base_common(repo_list=None):
    import dnf
    import dnf.base
    import dnf.conf

    # 预先构造 Conf 并设置 releasever，避免 dnf.Base() 在 _setup_default_conf()
    # 中调用 detect_releasever() 去打开容器宿主 rpmdb（会报 "rpmdb open failed"）
    conf = dnf.conf.Conf()
    conf.substitutions['releasever'] = ''
    base = dnf.Base(conf)
    # disable systemd repo
    base.repos.all().disable()
    base.conf.sslverify = False
    dnf.rpm.transaction.rpm.addMacro('_dbpath', '/var/lib/rpm')
    
    for repo_info in repo_list:
        repo = base.repos.add_new_repo(repo_info["name"], base.conf, baseurl=[repo_info["url"]])
        repo.enable()
    
    # load remote data
    base.fill_sack(load_system_repo=False, load_available_repos=True)
    return base


def get_default_repo_list(d):
    return [
        {
            "name": "remote_everything",
            "url": f"{d.getVar('SERVER_MIRROR')}/{d.getVar('SERVER_VERSION')}/everything/{d.getVar('TUNE_ARCH')}/"
        },
        {
            "name": "remote_epol", 
            "url": f"{d.getVar('SERVER_MIRROR')}/{d.getVar('SERVER_VERSION')}/EPOL/main/{d.getVar('TUNE_ARCH')}/"
        }
    ]
