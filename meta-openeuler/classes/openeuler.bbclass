# this class contains global method and variables for openeuler embedded

## openeuler.bbclass is inherited after base.bbclass,
## some definitions in it can be overridden here

# for openeuler embedded it is no need to create DL_DIR, here we use
# ${OPENEULER_SP_DIR}/${OPENEULER_LOCAL_NAME} to represent download
# directory for each software package. OPENEULER_SP_DIR
# is already created, and OPENEULER_LOCAL_NAME will be created
# in openeuler_fetch or fetch
# Thus, overrides the definition in base.bbclass
do_fetch[dirs] = "${OPENEULER_SP_DIR}"

# we can't use poky's original get_checksum_file_list in base.bbclass
# because of the src repo organization and special handling of DL_DIR
# here we override it with openeuler's implementation.
def openeuler_get_checksum_file_list(d):
    """ Get a list of files checksum in SRC_URI

    Returns the resolved local paths of all local file entries in
    SRC_URI (files in src repo will not be included) as a space-separated
    string
    """

    fetch = bb.fetch2.Fetch([], d, cache = False, localonly = True)

    dl_dir = d.getVar('OPENEULER_DL_DIR')
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
    import subprocess, os

    if d.getVar('OPENEULER_PREBUILT_TOOLS_ENABLE') != 'yes':
        return

    # when the version of rpm is 4.18.0+, we need add RPM_CONFIGDIR to env
    rpm_configdir = oe.path.join(d.getVar('OPENEULER_NATIVESDK_SYSROOT'), '/usr/lib/rpm')

    env = os.environ.copy()
    env["RPM_CONFIGDIR"] = rpm_configdir

    rpmdeps  = subprocess.Popen('rpm --eval="%{_rpmconfigdir}"', shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=env)
    stdout, stderr = rpmdeps.communicate()
    d.setVar('RPMDEPS', os.path.join(str(stdout, "utf-8").strip(), "rpmdeps --alldeps --define '__font_provides %{nil}'"))

    # export RPM_CONFIGDIR
    d.setVar('RPM_CONFIGDIR', rpm_configdir)
    d.setVarFlag('RPM_CONFIGDIR', 'export', '1')
}

addhandler set_rpmdeps
set_rpmdeps[eventmask] = "bb.event.RecipePreFinalise"

# do_unpack does not depends on xz-native， avoid dependency loops
python() {
    all_depends = d.getVarFlag("do_unpack", "depends") or ''
    for dep in ['xz']:
        all_depends = all_depends.replace('%s-native:do_populate_sysroot' % dep, "")
    new_depends = all_depends
    d.setVarFlag("do_unpack", "depends", new_depends)
}


# use the the latest commit time output from git log of (yocto-meta-openeuler)
def get_openeuler_epoch(d):
    import subprocess
    import time

    # get the .git dir of yocto-meta-openeuler
    gitpath = d.getVar("LAYERDIR_openeuler")
    if gitpath is not None:
        gitpath += "/../.git"
    else:
        # Handle the case when LAYERDIR_openeuler is not defined
        raise ValueError("LAYERDIR_openeuler is not defined")

    try:
        # run git -c log.showSignature=false --git-dir <path-to-yocto-meta-openeuler-git> log -1 --pretty=%ct
        p = subprocess.run(['git', '-c', 'log.showSignature=false', '--git-dir', gitpath, 'log', '-1', '--pretty=%ct'],
                           check=True, stdout=subprocess.PIPE)

        return int(p.stdout.decode('utf-8'))

    except subprocess.CalledProcessError as e:
        # Log the error and fallback to current time
        bb.warn("Error running git command: %s" % str(e))
        return int(time.time())

    except Exception as e:
        # Handle other exceptions
        bb.warn("An unexpected error occurred: %s" % str(e))
        return int(time.time())

# src_uri_set is used to remove some URLs from SRC_URI through
# OPENEULER_SRC_URI_REMOVE, because we don't want to download from
# these URLs
# this anonymous function is executed before any task
python src_uri_set() {
    src_uri = d.getVar('SRC_URI')
    remove_list = d.getVar('OPENEULER_SRC_URI_REMOVE')
    local_name = d.getVar('OPENEULER_LOCAL_NAME')

    # if software recipe is not in manifest.yaml, we will skip the handling of
    # OPENEULER_SRC_URI_REMOVE and it also means the software recipe is not
    # adapted in openEuler, use original fetch
    if d.getVar("MANIFEST_DIR") is not None and os.path.exists(d.getVar("MANIFEST_DIR")):
        manifest_list = d.getVar("MANIFEST_LIST")
        if local_name not in manifest_list:
            d.setVar('OPENEULER_FETCH', 'disable')
            return

    # handle the SRC_URI
    if src_uri and remove_list:
        uri_list = src_uri.split()
        remove_list = remove_list.split()

        updated_uri_list = [uri for uri in uri_list if not any(uri.strip().startswith(remove_item.strip()) for remove_item in remove_list)]
        updated_src_uri = ' '.join(updated_uri_list)

        d.setVar('SRC_URI', updated_src_uri)

    # all recipes adapted in openeuler will not be cached during bb parsing if BB_SRCREV_POLICY
    # is not set to cache
    # so there will alway be a chance to update SRCREV
    if d.getVar('BB_SRCREV_POLICY') != "cache":
        d.setVar('BB_DONT_CACHE', '1')
    # set SRCREV, if SRCREV changed because of the corresponding changes in manifest.yaml,
    # do_fetch will re-run
    repo_item = manifest_list[local_name]
    d.setVar('SRCREV', repo_item['version'])
}

addhandler src_uri_set
# this event needs to run before the anonymous function defined base.bbclass,
# and after the set_openeuler_variable event defined in openeuler_source.bbclass
src_uri_set[eventmask] = "bb.event.RecipePostKeyExpansion"


# call "do_openeuler_fetch" at the beginning of do_fetch,
# it will fetch software packages, the related patches and other files
# from openeuler's gitee repo.
# if success,  other part of base_do_fetch will skip download as
# files are already downloaded by do_openeuler_fetch
python base_do_fetch:prepend() {
    bb.build.exec_func("do_openeuler_fetch", d)
}

# fetch software packages from openeuler's repos first,
# if failed, go to the original do_fetch defined in
# base.bbclass
python do_openeuler_fetch() {
    import os
    import shutil
    import git
    from git import GitError

    # for fake recipes without SRC_URI pass
    src_uri = (d.getVar('SRC_URI') or "").split()
    if len(src_uri) == 0:
        return

    if d.getVar('OPENEULER_FETCH') == "disable":
        return

    def openeuler_fetch(d, repo_name):
        # get source directory where to download
        src_dir = d.getVar('OPENEULER_SP_DIR')
        # local download path
        repo_dir = os.path.join(src_dir, repo_name)

        try:
            # determine whether the variable MANIFEST_DIR is None
            if d.getVar("MANIFEST_DIR") is not None and os.path.exists(d.getVar("MANIFEST_DIR")):
                manifest_list = d.getVar("MANIFEST_LIST")
                if repo_name in manifest_list:
                    repo_item = manifest_list[repo_name]
                    download_repo(d, repo_dir, repo_item['remote_url'], repo_item['version'])
            else:
                bb.fatal("openEuler Embedded build need manifest.yaml")
        except GitError as e:
            bb.fatal("could not find or init gitee repository %s because %s" % (repo_name, str(e)))
        except Exception as e:
            bb.fatal("do_openeuler_fetch failed: OPENEULER_SP_DIR %s OPENEULER_LOCAL_NAME %s exception %s" % (src_dir, repo_name, str(e)))

    repo_list = d.getVar("OPENEULER_REPO_NAMES").split()
    for repo_name in repo_list:
        # download code from openEuler
        openeuler_fetch(d, repo_name)
}

def init_repo_dir(repo_dir):
    import git

    repo = git.Repo.init(repo_dir)

    with repo.config_writer() as wr:
        wr.set_value('http', 'sslverify', 'false').release()
    return repo

# init repo in repo_dir from manifest file
def download_repo(d, repo_dir, repo_url ,version = None):
    import os
    import git
    from git import GitCommandError
    import subprocess
    import re

    def sync_repo_from_cache(d, repo_dir):
        base_name = os.path.basename(repo_dir)
        cache_repo_dir = os.path.join(d.getVar('CACHE_SRC_DIR'), base_name)
        if os.path.exists(cache_repo_dir):
            subprocess.run(f"rsync -a {cache_repo_dir}/ {repo_dir}/", shell=True)

    lock_file = os.path.join(repo_dir, "file.lock")
    lf = bb.utils.lockfile(lock_file, block=True)

    # note: bb.utils.lockfile will mkdir directory if not exists
    dir_list = os.listdir(repo_dir)
    if len(dir_list) ==1 and dir_list[0] == "file.lock":
        # here we sync repo from cache, note when repo is not exist we sync
        if d.getVar('CACHE_SRC_DIR'):
            sync_repo_from_cache(d, repo_dir)

    repo = init_repo_dir(repo_dir)
    remote = None
    for item in repo.remotes:
        # for the accuracy of comparison, remove the ".git" from the end of both strings
        if repo_url.rstrip(".git") == item.url.rstrip(".git"):
            remote = item
        else:
            continue
    if remote is None:
        remote_name = "upstream"
        remote = git.Remote.add(repo = repo, name = remote_name, url = repo_url)

    # This download function is only used for downloading oee_archive which holds tar packages, it can
    # download what you want, and only what you need, no more others. In order to do this, we use git 
    # sparse-checkout, which reduces your working tree to a subset of
    # tracked files. You can see more detail by visiting https://git-scm.com/docs/git-sparse-checkout
    def oee_archive_download(oee_archive_dir:str, subdir: str):
        # if exists subdir and return
        if os.path.exists(os.path.join(oee_archive_dir, sub_dir)):
            return
        res = subprocess.run("git sparse-checkout init",
                        shell=True,
                        stderr=subprocess.PIPE,
                        text=True,
                        cwd=oee_archive_dir)
        if res.returncode != 0:
            bb.fatal(f"in oee_archive run git sparse-checkout init faild, error: {res.stderr}")
        res = subprocess.run(f"git sparse-checkout list | grep {subdir}", shell=True, cwd=oee_archive_dir)
        if res.returncode == 0:
            return
        res = subprocess.run(f"git sparse-checkout add {subdir}",
                        shell=True,
                        stderr=subprocess.PIPE,
                        text=True,
                        cwd=oee_archive_dir)
        if res.returncode != 0:
            bb.fatal(f"in oee_archive run git sparse-checkout add {subdir} faild, error: {res.stderr}")

    if "oee_archive" in repo_url:
        sub_dir = d.getVar("OEE_ARCHIVE_SUB_DIR")
        if sub_dir is None:
            bb.fatal("no sub dir is givned under oee_archive ")
        oee_archive_download(oee_archive_dir = repo_dir, subdir = sub_dir)

    # the function is used to download large file in repo
    def lfs_download(repo_dir, remote_name, version):
        res = subprocess.run(f"git lfs fetch {remote_name} {version}",
                            shell=True,
                            cwd=repo_dir,
                            encoding="utf-8",
                            stderr=subprocess.PIPE)
        if res.returncode != 0:
            bb.fatal(res.stderr)
        res = subprocess.run(f"git lfs checkout {version}",
                            shell=True,
                            cwd=repo_dir,
                            encoding="utf-8",
                            stderr=subprocess.PIPE)
        if res.returncode != 0:
            bb.fatal(res.stderr)

    try:
        # if get commit version, just return
        repo.commit(version)
    except:
        bb.debug(1, 'commit does not exist, shallow fetch: ' + version)
        remote.fetch(version, depth=1)

    # here, we use try to avoid users modify the repo, if user modified, just given warning
    try:
        repo.git.checkout(version)
    except:
        bb.warn("the version %s checkout failed ..." , version)

    # if the repo has large file it will has .gitattrbutes
    if os.path.exists(repo_dir+"/.gitattributes"):
        lfs_download(repo_dir=repo_dir, remote_name=remote.name, version=version)

    bb.utils.unlockfile(lf)


# store YAML data within MANIFEST_LIST variable
addhandler parse_manifest
python parse_manifest() {
    # used to read YAML file data
    def get_manifest(manifest_yaml):
        import yaml

        with open(manifest_yaml, 'r' ,encoding="utf-8") as r_f:
            return yaml.load(r_f.read(), yaml.Loader)['manifest_list']

    d.setVar('MANIFEST_LIST', get_manifest(d.getVar("MANIFEST_DIR")))
}
parse_manifest[eventmask] = "bb.event.ConfigParsed"

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

    src_dir = d.getVar('OPENEULER_SP_DIR')
    repo_name = d.getVar("OPENEULER_LOCAL_NAME")
    repo_dir = os.path.join(src_dir, repo_name)
    remove_lock(repo_dir)
}

addtask do_openeuler_clean before do_clean
