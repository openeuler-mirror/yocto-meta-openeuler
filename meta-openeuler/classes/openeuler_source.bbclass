# this bbclass is used to make a match between package name in recipe and the real package tarball name in openeuler
# the mismatch is caused by a lot of reasons.
#  - multiple packages share the same git repo, e.g. rcl_interfaces of openeuler contains multiple packages's src tarball
#  - the special handling of ros2 related packages in openeuler

def check_class_valid(d):
    is_diable = d.getVar('DISABLE_OPENEULER_SOURCE_MAP')
    if is_diable is None or is_diable == "False" or is_diable == "false" or is_diable == "0":
        return True
    return False

def openeuler_set_version(d):
    new_pv = openeuler_get_item(d, 'PV', "")
    if new_pv:
        d.setVar('PV', '%s'%new_pv)

def openeuler_set_localname(d):
    new_localname = openeuler_get_item(d, 'localname', "")
    if new_localname:
        d.setVar('OPENEULER_LOCAL_NAME', '%s' % new_localname)

def openeuler_get_item(d, key, default_value):
    pkg_name = d.getVar('BPN')
    if d.getVar("MAPLIST_DIR") is not None and os.path.exists(d.getVar("MAPLIST_DIR")):
        localname_list = get_localname_list(d.getVar("MAPLIST_DIR"))
        if pkg_name in localname_list:
            pkg_item = localname_list[pkg_name]
            if key in pkg_item:
                return pkg_item[key]
    return default_value

# read localname_list from maplist file
def get_localname_list(maplist_dir):
    import yaml

    with open(maplist_dir, 'r' ,encoding="utf-8") as r_f:
        return yaml.load(r_f.read(), yaml.Loader)['localname_list']



# handle the license warning found in ROS2 support
# the warning is caused by the unmatch between meta-ros and yocto-poky
python set_openeuler_variable() {

    license_mapping = {
        "LGPL": "LGPL-2.1-or-later",
        "BSD": "BSD-3-Clause"
    }

    license = d.getVar("LICENSE")

    if license in license_mapping:
        d.setVar("LICENSE", license_mapping[license])

    if check_class_valid(d):
        openeuler_set_version(d)
        openeuler_set_localname(d)
        if check_source_list(d):
            bb.build.exec_func("add_openeuler_source_uri", d)
}

addhandler set_openeuler_variable
set_openeuler_variable[eventmask] = "bb.event.RecipePreFinalise"
#set_openeuler_variable[eventmask] = "bb.event.RecipePreFinalise bb.event.RecipeParsed bb.event.ParseStarted bb.event.ParseCompleted bb.event.RecipeTaskPreProcess"

# check whether the package is in maplist file
def check_source_list(d):
    pkg_name = d.getVar('BPN')
    if d.getVar("MAPLIST_DIR") is not None and os.path.exists(d.getVar("MAPLIST_DIR")):
        localname_list = get_localname_list(d.getVar("MAPLIST_DIR"))
        if pkg_name in localname_list:
            return True
    return False

python add_openeuler_source_uri() {
    tarballs = []
    localname = d.getVar("OPENEULER_LOCAL_NAME")
    workspace_tarball_list = openeuler_get_item(d, 'workspace_tarball', "")
    for workspace_tarball in workspace_tarball_list:
        tarballs.append(" file://" + localname + "/" + workspace_tarball.split()[-1] +
                ";subdir=" + workspace_tarball.split()[0] + ";striplevel=1")
    d.setVar('SRC_URI', '%s %s' % (' '.join(tarballs), d.getVar("SRC_URI")))
}
