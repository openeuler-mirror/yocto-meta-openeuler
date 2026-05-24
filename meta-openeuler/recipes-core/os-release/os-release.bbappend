# reference: openbmc/recipes-core/os-release/os-release.bbappend

# WARNING!
#
# These modifications to os-release disable the bitbake parse
# cache (for the os-release recipe only).  Before copying
# and pasting into another recipe ensure it is understood
# what that means!

def get_oee_revision(d):
    try:
        import git
        repo_dir = oe.path.join(d.getVar("OPENEULER_SP_DIR"), "yocto-meta-openeuler")
        repo = git.Repo(repo_dir)
        return repo.head.object.hexsha
    except Exception:
        # gitpython not available or repo not found — fall back to a safe default
        import subprocess, os
        repo_dir = oe.path.join(d.getVar("OPENEULER_SP_DIR"), "yocto-meta-openeuler")
        try:
            result = subprocess.run(
                ["git", "-C", repo_dir, "rev-parse", "HEAD"],
                capture_output=True, text=True
            )
            if result.returncode == 0:
                return result.stdout.strip()
        except Exception:
            pass
        return "unknown"

# Use immediate variable expansion here.
# Other variable expansion syntax cannot triger os-release rebuild
# after yocto-meta-openeuler HEAD hexsha changed.
OEE_REVISION := "${@get_oee_revision(d)}"

OS_RELEASE_FIELDS:append = " BUILD_ID OEE_REVISION"

# Ensure the git commands run every time bitbake is invoked.
BB_DONT_CACHE = "1"

ASSUME_PROVIDE_PKGS:${PN} = "openEuler-repos openEuler-release openEuler-gpg-keys"
