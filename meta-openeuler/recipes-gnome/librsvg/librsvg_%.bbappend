# main bb: openembedded-core/meta/recipes-gnome/librsvg/librsvg_2.57.1.bb
#   annotations have been made for certain conflicting configurations in the 
#   source recipe, marked as: 'replace by oe'

OPENEULER_LOCAL_NAME = "librsvg2"

# remove cargo_common rust cargo-update-recipe-crates, use openeuler's cargo.bbclass
inherit cargo_bin gnomebase pixbufcache gobject-introspection vala gi-docgen

# prevent being overwritten by autotools from gnomebase
do_configure[postfuncs] += "cargo_bin_do_configure"

# fix err target generated by autotools from gnomebase
export RUST_TARGET

PV = "2.57.92"

SRC_URI:prepend = " \
    file://librsvg-${PV}.tar.xz \
    file://vendor.tar.xz \
"

S = "${WORKDIR}/librsvg-${PV}"

# use local deps, provided by source tarball
create_cargo_config:append() {
    cat <<- EOF >> ${CARGO_HOME}/config
[source.crates-io]
replace-with = "local-registry"

[source.local-registry]
directory = "vendor"

EOF
}
