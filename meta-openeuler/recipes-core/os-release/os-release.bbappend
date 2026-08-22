# reference: openbmc/recipes-core/os-release/os-release.bbappend

# WARNING!
#
# These modifications to os-release disable the bitbake parse
# cache (for the os-release recipe only).  Before copying
# and pasting into another recipe ensure it is understood
# what that means!

def get_oee_revision(d):
    import os
    import git

    # Locate yocto-meta-openeuler via the meta-openeuler layer dir (the
    # workspace layer being built) instead of OPENEULER_SP_DIR, which points
    # at the download cache and may not hold the layer repo. Mirrors
    # get_openeuler_epoch in openeuler.bbclass.
    layer_dir = d.getVar("LAYERDIR_openeuler")
    if layer_dir is None:
        raise ValueError("LAYERDIR_openeuler is not defined")
    repo_dir = os.path.dirname(layer_dir)

    repo = git.Repo(repo_dir)

    return repo.head.object.hexsha

# Use immediate variable expansion here.
# Other variable expansion syntax cannot triger os-release rebuild
# after yocto-meta-openeuler HEAD hexsha changed.
OEE_REVISION := "${@get_oee_revision(d)}"

OS_RELEASE_FIELDS:append = " BUILD_ID OEE_REVISION"

# Ensure the git commands run every time bitbake is invoked.
BB_DONT_CACHE = "1"

ASSUME_PROVIDE_PKGS:${PN} = "openEuler-repos openEuler-release openEuler-gpg-keys"
