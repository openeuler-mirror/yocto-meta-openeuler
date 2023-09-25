# this class contains global method and variables for openeuler embedded

## openeuler.bbclass is inherited after base.bbclass,
## some definitions in it can be overridden here

# for openeuler embedded no need to create DL_DIR, here is
# ${OPENEULER_SP_DIR}/${OPENEULER_REPO_NAME}, OPENEULER_SP_DIR
# is already created, and OPENEULER_REPO_NAME will be created
# in openeuler fetch or fetch
# overrides the definition in base.bbclass
do_fetch[dirs] = "${OPENEULER_SP_DIR}"

# we can't user poky's original get_checksum_file_list in base.bbclass
# because of the src repo organization and special handling of DL_DIR
# here we override it with openeuler's implementation.
def openeuler_get_checksum_file_list(d):
    """ Get a list of files checksum in SRC_URI

    Returns the resolved local paths of all local file entries in
    SRC_URI (files in src repo will not be included) as a space-separated
    string
    """

    fetch = bb.fetch2.Fetch([], d, cache = False, localonly = True)

    dl_dir = d.getVar('DL_DIR')
    filelist = []
    for u in fetch.urls:
        if u.startswith("file://"):
            ud = fetch.ud[u]
            if ud:
                paths = ud.method.localpaths(ud, d)
                for f in paths:
                    if os.path.exists(f) and not f.startswith(dl_dir):
                        filelist.append(f + ":True")

    return " ".join(filelist)

do_fetch[file-checksums] += "${@openeuler_get_checksum_file_list(d)}"

# set_rpmdpes is used to set RPMDEPS which comes from nativesdk/host
python set_rpmdeps() {
    import subprocess
    rpmdeps  = subprocess.Popen('rpm --eval="%{_rpmconfigdir}"', shell=True, stdout=subprocess.PIPE)
    stdout, stderr = rpmdeps.communicate()
    d.setVar('RPMDEPS', os.path.join(str(stdout, "utf-8").strip(), "rpmdeps --alldeps --define '__font_provides %{nil}'"))
}

addhandler set_rpmdeps
set_rpmdeps[eventmask] = "bb.event.RecipePreFinalise"

# use the the latest commit time output from git log of (yocto-meta-openeuler)
def get_openeuler_epoch(d):
    import subprocess
    import time

    # get the .git dir of yocto-meta-openeuler
    gitpath = d.getVar("LAYERDIR_openeuler") + "/../.git"

    # run git -c log.showSignature=false --git-dir <path-to-yocto-meta-openeuler-git> log -1 --pretty=%ct
    p = subprocess.run(['git', '-c', 'log.showSignature=false', '--git-dir', gitpath, 'log', '-1', '--pretty=%ct'],
                       check=True, stdout=subprocess.PIPE)

    if p.returncode != 0:
    # if failed return current time
        bb.warn(1, "%s does not have a valid date: %s" % (gitpath, p.stdout.decode('utf-8')))
        return int(time.time())

    return int(p.stdout.decode('utf-8'))

# set BUILD_LDFLAGS for native recipes buildings, nativesdk can be
# a star point for the necessary build-required recipes, no need to do
# everything from the scratch
BUILD_LDFLAGS:append = " -L${OPENEULER_NATIVESDK_SYSROOT}/usr/lib \
                         -L${OPENEULER_NATIVESDK_SYSROOT}/lib \
                         -Wl,-rpath-link,${OPENEULER_NATIVESDK_SYSROOT}/usr/lib \
                         -Wl,-rpath-link,${OPENEULER_NATIVESDK_SYSROOT}/lib \
                         -Wl,-rpath,${OPENEULER_NATIVESDK_SYSROOT}/usr/lib \
                         -Wl,-rpath,${OPENEULER_NATIVESDK_SYSROOT}/lib"

# src_uri_set is used to remove some URLs from SRC_URI through
# OPENEULER_SRC_URI_REMOVE, because we don't want to download from
# these URLs
python src_uri_set() {
    if d.getVar('OPENEULER_SRC_URI_REMOVE'):
        REMOVELIST = d.getVar('OPENEULER_SRC_URI_REMOVE').split(' ')
        URI = []
        for line in d.getVar('SRC_URI').split(' '):
            URI.append(line)
            for removeItem in REMOVELIST:
                if line.strip().startswith(removeItem.strip()):
                    URI.pop()
                    break
        URI = ' '.join(URI)
        d.setVar('SRC_URI', URI)
}

addhandler src_uri_set
src_uri_set[eventmask] = "bb.event.RecipePreFinalise"

# qemu.bbclass; fix build error: the kernel is too old
OLDEST_KERNEL:forcevariable = "5.10"

# fetch multi repos in one recipe bb file, an example is
# dsoftbus_1.0.bb where multi repos required by dsoftbus are
# fetched by re-implementation of do_fetch, and it will call
# do_openeuler_fetches
python do_openeuler_fetchs() {

    # Stage the variables related to the original package
    repoName = d.getVar("OPENEULER_REPO_NAME")
    localName = d.getVar("OPENEULER_LOCAL_NAME")
    gitUrl = d.getVar("OPENEULER_GIT_URL")
    branch = d.getVar("OPENEULER_BRANCH")

    repoList = d.getVar("PKG_REPO_LIST")
    for item in repoList:
        d.setVar("OPENEULER_REPO_NAME", item["repo_name"])
        if "git_url" in item:
            d.setVar("OPENEULER_GIT_URL", item["git_url"])
        if "branch" in item:
            d.setVar("OPENEULER_BRANCH", item["branch"])
        if "local" in item:
            d.setVar("OPENEULER_LOCAL_NAME", item["local"])
        else:
            d.setVar("OPENEULER_LOCAL_NAME", item["repo_name"])

        bb.build.exec_func("do_openeuler_fetch", d)

    # Restore the variables related to the original package
    d.setVar("OPENEULER_REPO_NAME", repoName)
    d.setVar("OPENEULER_LOCAL_NAME", localName)
    d.setVar("OPENEULER_GIT_URL", gitUrl)
    d.setVar("OPENEULER_BRANCH", branch)
}

# fetch software package from openeuler's repos first,
# if failed, go to the original do_fetch defined in
# base.bbclass
python do_openeuler_fetch() {
    import os
    import shutil
    import git
    from git import GitError

    # get source directory where to download
    srcDir = d.getVar('OPENEULER_SP_DIR')
    repoName = d.getVar('OPENEULER_REPO_NAME')
    localName = d.getVar('OPENEULER_LOCAL_NAME') if d.getVar('OPENEULER_LOCAL_NAME')  else repoName
    gitUrl = d.getVar('OPENEULER_GIT_URL')
    repoBranch = d.getVar('OPENEULER_BRANCH')

    urls = d.getVar("SRC_URI").split()

    # for fake recipes without SRC_URI pass
    src_uri = (d.getVar('SRC_URI') or "").split()
    if len(src_uri) == 0:
        return

    repo_dir = os.path.join(srcDir, localName)
    repo_url = os.path.join(gitUrl, repoName)
    except_str = None

    try:
        # determine whether the variable MANIFEST_DIR is None
        if d.getVar("MANIFEST_DIR") is not None and os.path.exists(d.getVar("MANIFEST_DIR")):
            manifest_list = get_manifest(d.getVar("MANIFEST_DIR"))
            if localName in manifest_list:
                repo_item = manifest_list[localName]
                download_repo(repo_dir = repo_dir, repo_url = repo_item['remote_url'], version = repo_item['version'])
        else:
            bb.fatal("openEuler Embedded build need manifest.yaml")
    except GitError:
        # can't use bb.fatal here, because there are the following cases:
        # case1:
        #      gitee repo exists, but git clone failed, then do_openeuler_fetch
        #      should re-run, so bb.fatal is required
        # case2:
        #      gitee repo does not exist, then try the original fetch, i.e.
        #      bb.fetch2.Fetch, so bb.fatal cannot be used
        # case3:
        #     all SRC_URI are in local, no need to do git clone, do_openeuler_fetch
        #     should bypass,the original fetch
        bb.note("could not find or init gitee repository {}".format(repoName))
    except Exception as e:
        bb.plain("===============")
        bb.plain("OPENEULER_SP_DIR: {}".format(srcDir))
        bb.plain("OPENEULER_REPO_NAME: {}".format(repoName))
        bb.plain("OPENEULER_LOCAL_NAME: {}".format(localName))
        bb.plain("OPENEULER_GIT_URL: {}".format(gitUrl))
        bb.plain("OPENEULER_BRANCH: {}".format(repoBranch))
        bb.plain("===============")
        except_str = str(e)

    if except_str != None:
        bb.fatal(except_str)
}

def init_repo_dir(repo_dir):
    import git

    repo = git.Repo.init(repo_dir)

    with repo.config_writer() as wr:
        wr.set_value('http', 'sslverify', 'false').release()
    return repo

# init repo in repo_dir from manifest file
def download_repo(repo_dir, repo_url ,version = None):
    import git
    from git import GitCommandError

    lock_file = os.path.join(repo_dir, "file.lock")
    lf = bb.utils.lockfile(lock_file, block=True)

    repo = init_repo_dir(repo_dir)
    remote = None
    for item in repo.remotes:
        if repo_url == item.url:
            remote = item
        else:
            continue
    if remote is None:
        remote_name = "upstream"
        remote = git.Remote.add(repo = repo, name = remote_name, url = repo_url)

    try:
        repo.commit(version)
    except:
        bb.debug(1, 'commit does not exist, shallow fetch: ' + version)
        remote.fetch(version, depth=1)

    # if repo is modified, restore it
    if repo.is_dirty():
        repo.git.checkout(".")
    repo.git.checkout(version)

    bb.utils.unlockfile(lf)

def get_manifest(manifest_dir):
    import yaml

    with open(manifest_dir, 'r' ,encoding="utf-8") as r_f:
        return yaml.load(r_f.read(), yaml.Loader)['manifest_list']
# do openeuler fetch at the beginning of do_fetch,
# it will fetch software packages and its patches and other files
# from openeuler's gitee repo.
# if success,  other part of base_do_fetch will skip download as
# files are already downloaded by do_openeuler_fetch
python base_do_fetch:prepend() {
    if not d.getVar('OPENEULER_FETCH') or d.getVar('OPENEULER_FETCH') == "enable":
        bb.build.exec_func("do_openeuler_fetch", d)
}

python do_openeuler_clean() {
    import os

    def remove_lock(dir):
        lock_file = os.path.join(dir, "file.lock")
        try:
            os.remove(lock_file)
            return True
        except FileNotFoundError:
            return True
        except:
            return False

    srcDir = d.getVar('OPENEULER_SP_DIR')

    repoList = d.getVar('PKG_REPO_LIST')
    if repoList != None:
        for item in repoList:
            repoDir = os.path.join(srcDir, item["repo_name"])
            remove_lock(repoDir)
    else:
        repoName = d.getVar("OPENEULER_REPO_NAME")
        repoDir = os.path.join(srcDir, repoName)
        remove_lock(repoDir)
}

addtask do_openeuler_clean before do_clean
