# main bbfile: meta-openeuler/recipes-gnome/gnome/adwaita-icon-theme_45.0.bb
# upstream recipe: openembedded-core adwaita-icon-theme_45.0.bb (OE master 已到 51.0,
# bb 保持目标版本 45.0 的上游原生配方, openeuler 适配统一放本 bbappend)

# use openeuler's pkg src (src-openeuler repo) instead of GNOME_MIRROR
SRC_URI = "file://${BP}.tar.xz"
SRC_URI[sha256sum] = "2442bfb06f4e6cc95bf6e2682fdff98fa5eddc688751b9d6215c623cb4e42ff1"
