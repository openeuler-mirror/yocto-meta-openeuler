OPENEULER_REPO_NAME = "yocto-embedded-tools"
OPENEULER_LOCAL_NAME = "ros-dev-tools"
OPENEULER_BRANCH = "dev_ros"
OPENEULER_GIT_URL = "https://gitee.com/openeuler"
OPENEULER_SRC_URI_REMOVE = "git https http"

def ros_dev_source(d):
    srcdir = d.getVar("OPENEULER_SP_DIR")
    srctxt = srcdir + "/ros-dev-tools/ros_depends/src.txt"
    basepkgname = d.getVar("BPN")
    if os.path.isfile(srctxt):
        f = open(srctxt)
        l = f.readline()
        while l:
            if basepkgname == l.split()[0]:
                return True
            l = f.readline()
        f.close()
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
    workdirbase = d.getVar("WORKDIR")
    srcdir = d.getVar("OPENEULER_SP_DIR")
    srctxt = srcdir + "/ros-dev-tools/ros_depends/src.txt"
    basepkgname = d.getVar("BPN")
    tarballdir = srcdir + "/ros-dev-tools/ros_depends/" + basepkgname
    tarball_with_workspace = []
    if os.path.isfile(srctxt):
        f = open(srctxt)
        l = f.readline()
        while l:
            l = l.strip()
            if basepkgname == l.split()[0]:
                tarball_with_workspace.append(tarballdir + "/" + l.split("/")[-1] + " " + l.split()[1])
            l = f.readline()
        f.close()
    for info in tarball_with_workspace:
        tarname = info.split()[0];
        targetdir = workdirbase + "/" + info.split()[1];
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

python add_openeuler_ros_uri() {
    import re
    srcdir = d.getVar("OPENEULER_SP_DIR")
    srctxt = srcdir + "/ros-dev-tools/ros_depends/src.txt"
    basepkgname = d.getVar("BPN")
    tarballdir = " file://ros-dev-tools/ros_depends/" + basepkgname
    tarballs = []
    if os.path.isfile(srctxt):
        f = open(srctxt)
        l = f.readline()
        while l:
            l = l.strip()
            if basepkgname == l.split()[0]:
                tarballs.append(tarballdir + "/" + l.split("/")[-1])
            l = f.readline()
        f.close()
    else:
        bb.warn("ROS PKGSOURCE: %s not exist" % srctxt)
    d.setVar('SRC_URI', '%s %s' % (' '.join(tarballs), d.getVar("SRC_URI")))
}

python srcuri_filter() {
    REMOVELIST = "git http https"
    URI = []
    for line in d.getVar('SRC_URI').split(' '):
        URI.append(line)
        for removeItem in REMOVELIST:
            if line.strip().startswith(removeItem.strip()):
                URI.pop()
                break
    URI = ' '.join(URI)
    d.setVar('SRC_URI', URI)
}

base_do_unpack_prepend() {
    if ros_dev_source(d):
        bb.build.exec_func("srcuri_filter", d)
        bb.build.exec_func("add_openeuler_ros_uri", d)
        bb.build.exec_func("clean_tarball_workspace", d)
}

do_unpack_append() {
    if ros_dev_source(d):
        bb.build.exec_func("prepare_tarball_workspace", d)
}

