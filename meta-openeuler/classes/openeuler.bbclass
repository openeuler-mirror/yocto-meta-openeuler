# this class contains global method and variables for openeuler embedded

# set_rpmdpes is used to set RPMDEPS which comes from nativesdk/host
python set_rpmdeps() {
    import subprocess
    rpmdeps = d.getVar('RPMDEPS', True)
    if not rpmdeps or rpmdeps == "default":
        rpmdeps  = subprocess.Popen('rpm --eval="%{_rpmconfigdir}"', shell=True, stdout=subprocess.PIPE)
        stdout, stderr = rpmdeps.communicate()
        d.setVar('RPMDEPS', os.path.join(str(stdout, "utf-8").strip(), "rpmdeps --alldeps --define '__font_provides %{nil}'"))
}

addhandler set_rpmdeps
set_rpmdeps[eventmask] = "bb.event.RecipePreFinalise"

# qemu.bbclass; fix build error: the kernel is too old
QEMU_OPTIONS_remove = "-r ${OLDEST_KERNEL}"

# fetch multi repos in one recipe bb file, an example is
# dsoftbus_1.0.bb where multi repos required by dsoftbus are
# fetched by re-implementation of do_fetch, and it will call
# do_openeuler_fetches
python do_openeuler_fetchs() {

    # Stage the variables related to the original package
    repoName = d.getVar("OPENEULER_REPO_NAME")
    gitSpace = d.getVar("OPENEULER_GIT_SPACE")
    branch = d.getVar("OPENEULER_BRANCH")

    repoList = d.getVar("PKG_REPO_LIST")
    for item in repoList:
        d.setVar("OPENEULER_REPO_NAME", item["repo_name"])
        if "git_space" in item:
            d.setVar("OPENEULER_GIT_SPACE", item["git_space"])
        if "branch" in item:
            d.setVar("OPENEULER_BRANCH", item["branch"])

        bb.build.exec_func("do_openeuler_fetch", d)

    # Restore the variables related to the original package
    d.setVar("OPENEULER_REPO_NAME", repoName)
    d.setVar("OPENEULER_GIT_SPACE", gitSpace)
    d.setVar("OPENEULER_BRANCH", branch)
}

# fetch software package from openeuler's repos first,
# if failed, go to the original do_fetch defined in
# base.bbclass
python do_openeuler_fetch() {
    import os
    import git
    import random
    import shutil
    from git import GitError

    # init repo in the repo_dir
    def init_repo(repoDir, repoPath, branch):
        try:
            # if repo has finished git init and then do git pull
            repo = git.Repo(repoDir)
            with repo.config_writer() as wr:
                wr.set_value('http', 'sslverify', 'false').release()
            repo.remote().pull()
            repo.git.checkout(branch)
            return
        except Exception as e:
            # do git init action in empty directory
            repo = git.Repo.init(repoDir)
            git.Remote.add(repo = repo, name = "origin", url = repoPath)
            with repo.config_writer() as wr:
                wr.set_value('http', 'sslverify', 'false').release()
            repo.remote().fetch()
            if repo.active_branch.name == branch:
                repo.active_branch.checkout()
            else:
                repo.git.checkout(branch)

    # add a file lock in the dir for compete
    def add_lock(dir):
            lock_file = os.path.join(dir, "file.lock")
            try:
                os.mknod(lock_file)
                return True
            except FileExistsError:
                return True
            except:
                return False

    def remove_lock(dir):
        lock_file = os.path.join(dir, "file.lock")
        try:
            os.remove(lock_file)
            return True
        except FileNotFoundError:
            return True
        except:
            return False

    # get source directory where to download
    srcDir = d.getVar('OPENEULER_SP_DIR')
    repoName = d.getVar('OPENEULER_REPO_NAME')
    gitPre = d.getVar('OPENEULER_GIT_PRE')
    gitSpace = d.getVar('OPENEULER_GIT_SPACE')
    repoBranch = d.getVar('OPENEULER_BRANCH')

    urls = d.getVar("SRC_URI").split()

    # for fake recipes without SRC_URI pass
    src_uri = (d.getVar('SRC_URI') or "").split()
    if len(src_uri) == 0:
        return

    isLock = False
    try:
        repoDir = os.path.join(srcDir, repoName)
        lockFile = os.path.join(repoDir, "file.lock")
        # checkout repo code
        repoUrl = os.path.join(gitPre, gitSpace, repoName + ".git")

        if not os.path.exists(repoDir):
            os.mkdir(repoDir)

            # create file.lock for other component compete
            add_lock(repoDir)
            isLock=True

            init_repo(repoDir, repoUrl, repoBranch)

            # delete lock file
            remove_lock(repoDir)
        else:
            while True:
                if os.path.exists(lockFile):
                # wait repo pull finished
                    time.sleep(random.randint(0,3))
                    continue
                else:
                    # create file.lock for other component compete
                    add_lock(repoDir)
                    isLock=True

                    # checkout repo code
                    init_repo(repoDir, repoUrl, repoBranch)

                    # delete lock file
                    remove_lock(repoDir)
                    break
    except GitError as gitError:
        if isLock:
            shutil.rmtree(repoDir)
            # remove_lock(repoDir)

        # if repoDir is empty and then delete it
        # if not os.listdir(repoDir):

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
        return
    except Exception as e:
        if isLock:
            shutil.rmtree(repoDir)
            # remove_lock(repoDir)

        # if repoDir is empty and then delete it
        # if not os.listdir(repoDir):

        bb.plain("===============")
        bb.plain("OPENEULER_SP_DIR: {}".format(srcDir))
        bb.plain("OPENEULER_REPO_NAME: {}".format(repoName))
        bb.plain("OPENEULER_GIT_PRE: {}".format(gitPre))
        bb.plain("OPENEULER_GIT_SPACE: {}".format(gitSpace))
        bb.plain("OPENEULER_BRANCH: {}".format(repoBranch))
        bb.plain("===============")

        bb.fatal(str(e))
}

# do openeuler fetch at the beginning of do_fetch,
# it will fetch software packages and its patches and other files
# from openeuler's gitee repo.
# if success,  other part of base_do_fetch will skip download as
# files are already downloaded by do_openeuler_fetch
python base_do_fetch_prepend() {
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
