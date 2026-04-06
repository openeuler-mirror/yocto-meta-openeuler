# this class is used to handle the situation where source code is staged in oee_archive repo
# (https://gitee.com/openeuler/oee_archive) or other archive repo
# oee_archive must be a git repo.

# the default repo name is oee_archive, which is used for do_openeuler_fetch
OEE_ARCHIVE_SUB_DIR ?= "${BPN}"
# for real file path to search is ${OPENEULER_LOCAL_NAME}/${OEE_ARCHIVE_SUB_DIR},
# not OPENEULER_LOCAL_NAME.
OEE_ARCHIVE_DIR = "${OPENEULER_SP_DIR}/oee_archive"

FILESEXTRAPATHS:prepend = "${OEE_ARCHIVE_DIR}/${OEE_ARCHIVE_SUB_DIR}/:"

# oee-archive.bbclass is always inherited in .bbappend file,
# this will cause the waring of QA "native-last"
# add native-last into INSANE_SKIP to avoid this warning.
# a better way is to try to inherit oee-archive.bbclass  before native.bbclass
INSANE_SKIP += "native-last"

def init_oee_archive_repo_dir(repo_dir):
    import git

    repo = git.Repo.init(repo_dir)

    with repo.config_writer() as wr:
        wr.set_value('http', 'sslverify', 'false').release()
    return repo

def init_oee_archive_repo_remote(repo, remote_url):
    existing = next((r for r in repo.remotes if r.name == "upstream"), None)
    if existing:
        if existing.url.rstrip(".git") != remote_url.rstrip(".git"):
            # URL changed, update remote
            repo.delete_remote(existing)
            repo.create_remote("upstream", remote_url)
        # else: URL is the same, no action needed
    else:
        repo.create_remote("upstream", remote_url)

def check_oee_archive_repo_version(repo, version):
    """
    check repo version
    """
    import git
    from git.exc import GitCommandError

    try:
        with repo.config_writer() as wr:
            wr.set_value('lfs', 'fetchexclude', '*').release()
        try:
            repo.git.fetch('upstream', version, '--depth=1')
            repo.git.checkout(version)
        finally:
            with repo.config_writer() as wr:
                wr.set_value('lfs', 'fetchexclude', '').release()
    except GitCommandError as e:
        # Use repo.working_dir to get the repository path
        raise Exception("version %s not found in repo %s, error: %s" % (version, repo.working_dir, e))

def pull_oee_archive_repo_sub_lfs(repo, sub_dir):
    """
    pull repo submodule lfs files
    """
    import git
    from git.exc import GitCommandError

    try:
        # Use the python-git module to execute git lfs pull, including only the specified subdirectory
        repo.git.lfs('pull', '--include', '%s/*' % sub_dir)
    except GitCommandError:
        raise Exception("pull repo submodule lfs files failed in repo %s" % sub_dir)

python do_download_oee_archive(){
    import os
    import subprocess

    # Initialize the oee_archive repo
    oee_archive_repo = init_oee_archive_repo_dir(d.getVar('OEE_ARCHIVE_DIR'))
    manifest_list = d.getVar('MANIFEST_LIST')
    if manifest_list is None:
        bb.fatal("do_download_oee_archive: MANIFEST_LIST is not set, check MANIFEST_DIR")
    if 'oee_archive' not in manifest_list:
        bb.fatal("do_download_oee_archive: 'oee_archive' entry not found in manifest.yaml")
    repo_item = manifest_list['oee_archive']
    # Add oee_archive remote
    init_oee_archive_repo_remote(oee_archive_repo, repo_item['remote_url'])
    # Check oee_archive version
    check_oee_archive_repo_version(oee_archive_repo, repo_item['version'])
    # Pull oee_archive submodule LFS files
    pull_oee_archive_repo_sub_lfs(oee_archive_repo, d.getVar('OEE_ARCHIVE_SUB_DIR'))
}

do_download_oee_archive[lockfiles] = "/tmp/openeuler/oee_archive.lock"
do_download_oee_archive[network] = "1"
addtask do_download_oee_archive before do_fetch
