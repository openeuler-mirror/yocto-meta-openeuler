# this class contains global method and variables for openeuler embedded

# set_rpmdpes is used to set RPMDEPS which comes from nativesdk/host
python set_rpmdeps() {
    import subprocess
    rpmdeps  = subprocess.Popen('rpm --eval="%{_rpmconfigdir}"', shell=True, stdout=subprocess.PIPE)
    stdout, stderr = rpmdeps.communicate()
    d.setVar('RPMDEPS', os.path.join(str(stdout, "utf-8").strip(), "rpmdeps --alldeps --define '__font_provides %{nil}'"))
}

addhandler set_rpmdeps
set_rpmdeps[eventmask] = "bb.event.RecipePreFinalise"

# set BUILD_LDFLAGS for use nativesdk lib
BUILD_LDFLAGS_append = " -L${OPENEULER_NATIVESDK_SYSROOT}/usr/lib \
                         -L${OPENEULER_NATIVESDK_SYSROOT}/lib \
                         -Wl,-rpath-link,${OPENEULER_NATIVESDK_SYSROOT}/usr/lib \
                         -Wl,-rpath-link,${OPENEULER_NATIVESDK_SYSROOT}/lib \
                         -Wl,-rpath,${OPENEULER_NATIVESDK_SYSROOT}/usr/lib \
                         -Wl,-rpath,${OPENEULER_NATIVESDK_SYSROOT}/lib"

# src_uri_set is used to remove some url with variable OPENEULER_SRC_URI_REMOVE
# that we set some head strings in, because we maybe does not need to download it 
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
OLDEST_KERNEL_forcevariable = "5.10"

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
    import fcntl
    
    import git
    from git import GitError

    # init repo in the repo_dir
    def init_repo(repo_dir, repo_url, repo_branch):
        try:
            # if repo has finished git init and then do git pull
            repo = git.Repo(repo_dir)
            with repo.config_writer() as wr:
                wr.set_value('http', 'sslverify', 'false').release()
            # If the repository only does fetch, it does not need to perform a pull
            if len(repo.branches) != 0:
                repo.remote().pull()
            else:
                repo.remote().fetch()
            repo.git.checkout(repo_branch)
            return
        except Exception as e:
            # do git init action in empty directory
            repo = git.Repo.init(repo_dir)
            git.Remote.add(repo = repo, name = "origin", url = repo_url)
            with repo.config_writer() as wr:
                wr.set_value('http', 'sslverify', 'false').release()
            repo.remote().fetch()
            if repo.active_branch.name == repo_branch:
                repo.active_branch.checkout()
            else:
                repo.git.checkout(repo_branch)

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
    if not os.path.exists(repo_dir):
        os.mkdir(repo_dir)
    repo_url = os.path.join(gitUrl, repoName + ".git")
    lock_file = os.path.join(repo_dir, "file.lock")
    except_str = None
    with open(lock_file, 'a', closefd=True) as f:
        fcntl.flock(f.fileno(), fcntl.LOCK_EX)
        try:
            init_repo(repo_dir = repo_dir, repo_url = repo_url, repo_branch = repoBranch)
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
            bb.note("could not find gitee repository {}".format(repoName))
        except Exception as e:
            bb.plain("===============")
            bb.plain("OPENEULER_SP_DIR: {}".format(srcDir))
            bb.plain("OPENEULER_REPO_NAME: {}".format(repoName))
            bb.plain("OPENEULER_LOCAL_NAME: {}".format(localName))
            bb.plain("OPENEULER_GIT_URL: {}".format(gitUrl))
            bb.plain("OPENEULER_BRANCH: {}".format(repoBranch))
            bb.plain("===============")
            except_str = str(e)

    if os.path.exists(lock_file):
        try:
            os.remove(lock_file)
        except:
            pass

    if except_str != None:
        bb.fatal(except_str)
}

# do openeuler fetch at the beginning of do_fetch,
# it will fetch software packages and its patches and other files
# from openeuler's gitee repo.
# if success,  other part of base_do_fetch will skip download as
# files are already downloaded by do_openeuler_fetch
python base_do_fetch_prepend() {    
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
