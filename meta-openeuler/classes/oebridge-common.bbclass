def init_base_common(repo_list=None):
    import dnf
    import dnf.base
    import dnf.conf

    base = dnf.Base()
    # disable systemd repo
    base.conf.substitutions['releasever'] = ''
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
