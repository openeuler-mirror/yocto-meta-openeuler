OPENEULER_SRC_URI_REMOVE = "git https http"

def openeuler_set_version(d):
    new_pv = openeuler_get_item(d, 'PV', "")
    if new_pv:
        d.setVar('PV', '%s'%new_pv)

def openeuler_get_localname(d):
    return openeuler_get_item(d, 'localname', "")

def openeuler_get_item(d, key, default_value):
    pkg_name = d.getVar('BPN')
    if d.getVar("MAPLIST_DIR") is not None and os.path.exists(d.getVar("MAPLIST_DIR")):
        localname_list = get_localname_list(d.getVar("MAPLIST_DIR"))
        if pkg_name in localname_list:
            pkg_item = localname_list[pkg_name]
            if key in pkg_item:
                return pkg_item[key]
    return default_value

def get_localname_list(maplist_dir):
    import yaml

    with open(maplist_dir, 'r' ,encoding="utf-8") as r_f:
        return yaml.load(r_f.read(), yaml.Loader)['localname_list']


python set_openeuler_variable() {
    openeuler_set_version(d)
    d.setVar('OPENEULER_LOCAL_NAME', '${@openeuler_get_localname(d)}')
    if check_source_list(d):
        bb.build.exec_func("add_openeuler_source_uri", d)
}

addhandler set_openeuler_variable
set_openeuler_variable[eventmask] = "bb.event.RecipePreFinalise"
#set_openeuler_variable[eventmask] = "bb.event.RecipePreFinalise bb.event.RecipeParsed bb.event.ParseStarted bb.event.ParseCompleted bb.event.RecipeTaskPreProcess"

def check_source_list(d):
    pkg_name = d.getVar('BPN')
    if d.getVar("MAPLIST_DIR") is not None and os.path.exists(d.getVar("MAPLIST_DIR")):
        localname_list = get_localname_list(d.getVar("MAPLIST_DIR"))
        if pkg_name in localname_list:
            return True
    return False

def rm_files(src_dir, dst_dir):
    import shutil
    if os.path.exists(src_dir):
        shutil.rmtree(src_dir)
    if os.path.exists(dst_dir):
        shutil.rmtree(dst_dir)

def copy_files(src_dir, dst_dir):
    import shutil
    if not os.path.exists(dst_dir):
        os.makedirs(dst_dir)
    if os.path.exists(src_dir):
        for file in os.listdir(src_dir):
            file_path = os.path.join(src_dir, file)
            dst_path = os.path.join(dst_dir, file)
            if os.path.isfile(os.path.join(src_dir, file)):
                shutil.copy2(file_path, dst_path)
            else:
                copy_files(file_path, dst_path)

def make_tarball_workspace(func, d):
    import tarfile
    import zipfile
    import re
    import os

    workdirbase = d.getVar("WORKDIR")
    localname = d.getVar("OPENEULER_LOCAL_NAME")
    srcdir = d.getVar("OPENEULER_SP_DIR")
    workspace_tarball_list = openeuler_get_item(d, 'workspace_tarball', "")
    for workspace_tarball in workspace_tarball_list:
        tarname = srcdir + "/" + localname + "/" + workspace_tarball.split()[-1]
        targetdir = workdirbase + "/" + workspace_tarball.split()[0]
        res = ""
        if os.path.isfile(tarname):
            if ".tar." in tarname:
                with tarfile.open(tarname, 'r') as tf:
                    res = tf.getnames()[0]
            elif tarname.endswith(".zip"):
                with zipfile.ZipFile(tarname, 'r') as zf:
                    res = zf.namelist()[0]
        if len(res) != 0:
            fromdir = workdirbase + "/" + res
            source = os.path.abspath(fromdir)
            target = os.path.abspath(targetdir)
            func(source, target)

python clean_tarball_workspace() {
    make_tarball_workspace(rm_files, d)
}

python prepare_tarball_workspace() {
    make_tarball_workspace(copy_files, d)
}

python add_openeuler_source_uri() {
    tarballs = []
    localname = d.getVar("OPENEULER_LOCAL_NAME")
    workspace_tarball_list = openeuler_get_item(d, 'workspace_tarball', "")
    for workspace_tarball in workspace_tarball_list:
        tarballs.append(" file://" + localname + "/" + workspace_tarball.split()[-1])
    d.setVar('SRC_URI', '%s %s' % (' '.join(tarballs), d.getVar("SRC_URI")))
}

base_do_unpack_prepend() {
    if check_source_list(d):
        bb.build.exec_func("clean_tarball_workspace", d)
}

do_unpack_append() {
    if check_source_list(d):
        bb.build.exec_func("prepare_tarball_workspace", d)
}

