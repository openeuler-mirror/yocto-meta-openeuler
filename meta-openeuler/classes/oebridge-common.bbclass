def init_base_common(repo_list=None):
    import dnf
    import dnf.base
    import dnf.conf
    import time

    # Retry the entire base construction + fill_sack on transient
    # RepoError (network/repo unavailable). Sibling recipes can succeed
    # the same task seconds apart, so the failure is intermittent.
    max_retries = 5
    for attempt in range(1, max_retries + 1):
        try:
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
        except Exception as e:
            if attempt < max_retries:
                bb.warn("init_base_common: fill_sack attempt %d/%d failed: %s, retrying in %ds..." % (attempt, max_retries, e, 2 * attempt))
                time.sleep(2 * attempt)
                continue
            raise


def get_default_repo_list(d):
    # Use TARGET_ARCH (not TUNE_ARCH): for target recipes TARGET_ARCH is the
    # target arch (e.g. aarch64); for nativesdk recipes it is the SDK host
    # arch (e.g. x86_64). TUNE_ARCH can be a Yocto-internal value (e.g. "arm"
    # for the nativesdk variant of an aarch64 build) that does not correspond
    # to any openEuler repo arch dir, causing a 404 on repomd.xml.
    # For allarch recipes TARGET_ARCH is "allarch" (no repo dir); fall back to
    # TUNE_ARCH (the MACHINE's base arch, e.g. aarch64 — noarch RPMs are in
    # every arch repo) or BUILD_ARCH (x86_64 build host). Note: TUNE_PKGARCH
    # can be a tune-specific value like "cortexa72" which is NOT a valid repo
    # dir; TUNE_ARCH gives the base arch (aarch64) which is valid.
    arch = d.getVar('TARGET_ARCH')
    if not arch or arch in ('all', 'allarch', ''):
        arch = d.getVar('TUNE_ARCH') or d.getVar('BUILD_ARCH') or 'x86_64'
    return [
        {
            "name": "remote_everything",
            "url": f"{d.getVar('SERVER_MIRROR')}/{d.getVar('SERVER_VERSION')}/everything/{arch}/"
        },
        {
            "name": "remote_epol", 
            "url": f"{d.getVar('SERVER_MIRROR')}/{d.getVar('SERVER_VERSION')}/EPOL/main/{arch}/"
        }
    ]
