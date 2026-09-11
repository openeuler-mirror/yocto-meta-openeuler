# packagegroup-container is a kitchen-sink recipe: its main package
# RDEPENDS on packagegroup-lxc / packagegroup-docker and its PACKAGES also
# builds the packagegroup-podman subpackage. Because Yocto packages at the
# recipe (PN) level, any image that consumes the widely used
# packagegroup-oci subpackage (e.g. packagegroup-k3s, packagegroup-kubernetes)
# also has to build docker-ce, podman, lxc, skopeo and their whole
# fetch/compile dependency chains -- even though none of them are installed
# into the images openEuler ships (they come from large go repos, slow to
# fetch and outright unreachable from restricted networks).
#
# yocto-meta-virtualization is a continuously synced upstream layer that
# openEuler does not carry local modifications for, so trim the recipe from
# this side instead: keep only the subpackages actually consumed by
# openEuler images -- packagegroup-oci (via k3s/kubernetes) and
# packagegroup-containerd (virtual-containerd).

RDEPENDS:${PN}:remove = "packagegroup-lxc packagegroup-docker"

PACKAGES:remove = "packagegroup-lxc packagegroup-docker packagegroup-podman"
