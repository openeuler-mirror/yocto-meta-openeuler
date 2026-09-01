# this class is used to handle the situation where source code is staged in oee_archive repo
# (https://gitee.com/openeuler/oee_archive) or other archive repo
# oee_archive must be a git repo.

# the default repo name is oee_archive, which is used for do_openeuler_fetch
OEE_ARCHIVE_SUB_DIR ?= "${BPN}"
# for real file path to search is ${OPENEULER_LOCAL_NAME}/${OEE_ARCHIVE_SUB_DIR},
# not OPENEULER_LOCAL_NAME.
OEE_ARCHIVE_DIR = "${OPENEULER_SP_DIR}/openeuler/oee_archive"

FILESEXTRAPATHS:prepend = "${OEE_ARCHIVE_DIR}/${OEE_ARCHIVE_SUB_DIR}/:"

# oee-archive.bbclass is always inherited in .bbappend file,
# this will cause the waring of QA "native-last"
# add native-last into INSANE_SKIP to avoid this warning.
# a better way is to try to inherit oee-archive.bbclass  before native.bbclass
INSANE_SKIP += "native-last"

# All recipes (and, on CI, all concurrent image builds) share ONE oee_archive
# git repo at OEE_ARCHIVE_DIR, which lives under the shared source cache
# OPENEULER_SP_DIR. Parallel do_download_oee_archive tasks race on the repo's
# on-disk locks: .git/config.lock (git init / config_writer), .git/shallow.lock
# (git fetch --depth=1), etc. A per-container /tmp lockfile cannot serialize
# across builds (each build has its own /tmp), so put the lockfile on the
# SHARED source cache path (OPENEULER_SP_DIR) to serialize across builds too.
do_download_oee_archive[lockfiles] = "${OPENEULER_SP_DIR}/oee_archive.lock"


def _oee_clear_stale_locks(git_dir):
    """Remove leftover git lock files (*.lock) under the repo's .git dir.

    do_download_oee_archive is serialized by its bitbake lockfile on the
    shared source cache, so no concurrent task is touching the repo; any
    leftover *.lock is stale (from a crashed/aborted earlier run) and can be
    removed safely."""
    import os
    if not git_dir or not os.path.isdir(git_dir):
        return
    for name in os.listdir(git_dir):
        if name.endswith(".lock"):
            try:
                os.remove(os.path.join(git_dir, name))
            except OSError:
                pass


def _oee_git_retry(fn, git_dir, max_retries=5):
    """Run a git operation fn(); retry on a stale-lock / 'File exists' error.

    Under the do_download_oee_archive bitbake lockfile no concurrent task
    touches the repo, so a leftover lock is stale. Remove it, back off, and
    retry a few times; only propagate the original error after exhausting
    retries (so the real git stderr reaches the user)."""
    import time
    for attempt in range(1, max_retries + 1):
        try:
            return fn()
        except Exception as e:
            msg = str(e)
            if attempt < max_retries and ('.lock' in msg or 'File exists' in msg or 'Unable to create' in msg):
                _oee_clear_stale_locks(git_dir)
                time.sleep(2 * attempt)
                continue
            raise


def init_oee_archive_repo_dir(repo_dir):
    import os
    import git

    git_dir = os.path.join(repo_dir, ".git")

    def _init():
        return git.Repo.init(repo_dir)

    repo = _oee_git_retry(_init, git_dir)

    def _set_sslverify():
        with repo.config_writer() as wr:
            wr.set_value('http', 'sslverify', 'false').release()

    _oee_git_retry(_set_sslverify, repo.git_dir)
    return repo


def init_oee_archive_repo_remote(repo, remote_url):
    def _setup_remote():
        existing = next((r for r in repo.remotes if r.name == "upstream"), None)
        if existing:
            if existing.url.rstrip(".git") != remote_url.rstrip(".git"):
                # URL changed, update remote
                repo.delete_remote(existing)
                repo.create_remote("upstream", remote_url)
            # else: URL is the same, no action needed
        else:
            repo.create_remote("upstream", remote_url)

    _oee_git_retry(_setup_remote, repo.git_dir)


def check_oee_archive_repo_version(repo, version):
    """
    check repo version
    """
    import git
    from git.exc import GitCommandError

    def _set_lfs_exclude():
        with repo.config_writer() as wr:
            wr.set_value('lfs', 'fetchexclude', '*').release()

    _oee_git_retry(_set_lfs_exclude, repo.git_dir)
    try:

        def _fetch_checkout():
            repo.git.fetch('upstream', version, '--depth=1')
            repo.git.checkout(version)

        # Let GitCommandError propagate on real failure so the actual git
        # stderr is shown (a stale .git/shallow.lock from a crashed fetch is
        # handled by _oee_git_retry instead of being mis-reported as
        # "version not found").
        _oee_git_retry(_fetch_checkout, repo.git_dir)
    finally:

        def _restore_lfs():
            with repo.config_writer() as wr:
                wr.set_value('lfs', 'fetchexclude', '').release()

        try:
            _oee_git_retry(_restore_lfs, repo.git_dir)
        except Exception:
            pass


def pull_oee_archive_repo_sub_lfs(repo, sub_dir):
    """
    pull repo submodule lfs files
    """
    import git
    from git.exc import GitCommandError

    def _lfs_pull():
        # Use the python-git module to execute git lfs pull, including only the specified subdirectory
        repo.git.lfs('pull', '--include', '%s/*' % sub_dir)

    try:
        _oee_git_retry(_lfs_pull, repo.git_dir)
    except GitCommandError as e:
        raise Exception("pull repo submodule lfs files failed in repo %s, error: %s" % (sub_dir, e))


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

do_download_oee_archive[network] = "1"
addtask do_download_oee_archive before do_fetch
