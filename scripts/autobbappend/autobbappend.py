#coding=utf-8
import re
from string import Template
import sys
import os
import argparse
import hashlib
import tarfile
from werkzeug import secure_filename

current_path = os.path.dirname(__file__)
src_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))
yocto_meta_openeuler_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))
yocto_meta_openeuler_meta_openeuler_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../meta-openeuler"))
yocto_poky_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../yocto-poky"))
yocto_poky_meta_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../yocto-poky/meta"))

def parse_args():
    parse = argparse.ArgumentParser(description='Automatically generates bbappend files.')  
    parse.add_argument('-s', '--spec', required=True, type=str, help='Enter the name or address of the spec file (Required).')  
    parse.add_argument('-b', '--bb',  type=str, help='Enter the name or address of the bb file.')
    parse.add_argument('-p', '--path',  type=str, help='Enter the search path for the bb file. The default is to search in /yocto-meta-openeuler/meta-openeuler first, and then in /yocto-poky/meta.')
    args = parse.parse_args()  
    return args 


def search_files(rootDir,filepathmsg,filetype):
    filepathresult = []
    for dirpath,dirNames,fileNames in os.walk(rootDir):
        for fileName in fileNames:
            apath = os.path.join(dirpath ,fileName)
            apathname = os.path.splitext(apath)[0]
            apathtype = os.path.splitext(apath)[1]
            for i in filetype:
                if i in apathtype:
                    for j in filepathmsg:
                        if j in apathname:
                            filepathresult.append(apath)
    for i in sorted(filepathresult):
        if not i.endswith(tuple(filetype)):
            filepathresult.remove(i)
    if len(filepathresult) == 0:
        dir = None   
    if len(filepathresult) == 1:
        dir = filepathresult[0]
        print(dir)
    if len(filepathresult) > 1:
        for i in range(len(filepathresult)):
            print('['+str(i)+']:'+filepathresult[i])
        num= input("Multiple files found, please enter the serial number of the file you want to select:")
        dir = filepathresult[int(num)]
    return dir


def search_specfile(spec):
    print("The following spec files were found:")
    if spec.endswith(".spec"):
        spec_dir = path_exists(spec)
        print(spec_dir)
    else:
        spec_dir = search_files(src_path,[spec],[".spec"])
        if spec_dir == None : 
            print("\033[31m[ERROR] : No spec files found.\033[0m")
            sys.exit()
    return spec_dir


def search_package(spec_dir):
    repo_path = os.path.dirname(spec_dir)
    f = open(secure_filename(repo_path))
    count = -1
    for count, line in enumerate(f.readlines()):
        count += 1
        if line.find('Name:') != -1: name = line.split(":")[1].strip()
        if line.find('Version:') != -1: version = line.split(":")[1].strip()
        if line.find('%global reldate') != -1: reldate = line.split("reldate")[1].strip()
        if line.find('Source0:') != -1 or line.find('Source:') != -1: 
            package = line.split("/")[-1].strip()
            if package.find("%{version}") != -1: package = package.replace("%{version}", version)
            if package.find("%{name}") != -1: package = package.replace("%{name}", name)
            if package.find("%{reldate}") != -1: package = package.replace("%{reldate}", reldate)
            package_dir = os.path.abspath(repo_path+"/"+package)
    f.close()
    if os.path.exists(package_dir) == False:
        print("The following packages were found:")
        package_dir = search_files(repo_path,[name,version],[".tar",".gz",".bz2",".xz"])
        if package_dir == None :
            print("\033[31m[ERROR] : No packages found in repo.\033[0m")
            sys.exit()
    return package_dir


def traversal_search_bb(bb_name):
    if args.path == None:
        bb_dir = search_files(yocto_meta_openeuler_meta_openeuler_path,[bb_name],[".bb",".inc"])
        if bb_dir == None:
            bb_dir = search_files(yocto_poky_meta_path,[bb_name],[".bb",".inc"])
            if bb_dir == None:
                print("\033[31m[ERROR] : No bb files found in /yocto-meta-openeuler/meta-openeuler and /yocto-poky/meta! Please enter the bb file address by args -b/--bb.\033[0m")
                sys.exit()
    else:
        path = path_exists(args.path)
        bb_dir = search_files(path,[bb_name],[".bb",".inc"])
        if bb_dir == None:
            print("\033[31m[ERROR] : No bb files found in %s! Please enter the bb file address by args -b/--bb.\033[0m"%path)
            sys.exit()
    return bb_dir


def search_bb_file(repo_name):
    print("The following bb files were found:")
    if args.bb == None:
        file_name = repo_name
    else:
        file_name = args.bb
    if file_name.endswith(".bb") or file_name.endswith(".inc"):
        bb_dir = path_exists(file_name)
        print(bb_dir)
    else:         
        bb_dir = traversal_search_bb(file_name) 
    return bb_dir


def generate_bbappend:path(bb_dir):
    (bbfile_path, name) = os.path.split(bb_dir)
    (bbfilefolder_path, bbfilefolder_name) = os.path.split(bbfile_path)
    (recipes_xxx_path, recipes_xxx_name) = os.path.split(bbfilefolder_path)
    bbappend:path = yocto_meta_openeuler_meta_openeuler_path+'/'+recipes_xxx_name+'/'+bbfilefolder_name
    return bbappend:path


def notes_bb_dir(bb_dir):
    if bb_dir.find("src") != -1: 
        bb_notes = bb_dir.split("src")[1].strip()
    else:
        bb_notes = bb_dir
    return bb_notes 


def read_name(spec_dir):
    f = open(secure_filename(spec_dir))
    count = -1
    for count, line in enumerate(f.readlines()):
        count += 1
        if line.find('Name:') != -1: name = line.split(":")[1].strip()
    f.close()
    return name


#OPENEULER_REPO_NAME used when the repository name is inconsistent with the ${BPN}.Refer to opkg-utils
def read_repo_name(spec_dir):
    (repo_path, spec_name) = os.path.split(spec_dir)
    (path, repo_name) = os.path.split(repo_path)
    if repo_name == bpn: repo_name = None
    return repo_name


def read_packageversion(spec_dir,package_dir):
    f = open(secure_filename(spec_dir))
    count = -1
    for count, line in enumerate(f.readlines()):
        count += 1
        if line.find('Version:') != -1: version = line.split(":")[1].strip()
    f.close()
    package = os.path.splitext(os.path.basename(package_dir))
    package = package[0].split('.tar')[0]
    parts = package.split('-')
    if len(parts) == 2:
        package_version = parts[1]
        if version != package_version:
            print("\033[33m[Warning] : The package version(%s) is inconsistent with the spec version(%s).\033[0m" %(package_version,version))
            version = package_version
    return version


def read_oldPV(pv,bb_dir):
    if pv == "git":
        bb_dir = secure_filename(bb_dir)
        f = open(bb_dir)
        count = -1
        for count, line in enumerate(f.readlines()):
            count += 1
            if line.find('PV = ') != -1: pv = line.split('"')[1].strip()
        f.close()
    return pv


def update_PV(packageversion,bbversion):
    if packageversion == bbversion : packageversion = None
    return packageversion


def read_patch(spec_dir):
    file = open(secure_filename(spec_dir))
    lines = file.readlines()
    result = []
    file.close()
    for i in lines:
        if re.search('^Patch[0-9]', i):
            result.append(i)
    m = '                   file://'
    a = r"\one"
    result2 = []
    for i in result:
        i = i.split()
        result2.append(m +i[-1]+ ' '+a[0])
    if len(result2):
        result2[0] = result2[0].strip()#Delete the '                   ' at the top
        result2[-1] = result2[-1].split("\\")[0].rstrip()#Delete the ' \' at the end
    if len(result2) == 0 :
        str = result2.append("None")
    else: 
        str = "\n".join(result2) 
    return str


def read_original_source(bb_dir):
    global remote_url
    remote_url = None
    f = open(secure_filename(bb_dir))
    count = -1
    for count, line in enumerate(f.readlines()):
        count += 1
        if line.find('SRC_URI = "') != -1: 
            remote_url = line.strip('SRC_URI = "')
            remote_url = remote_url.split('"')[0].strip()#Delete the '"' at the end
            remote_url = remote_url.split("\\")[0].strip()#Delete the ' \' at the end
    f.close()
    return remote_url


def read_local_source(package_dir):
    (package_path, package_name) = os.path.split(package_dir)
    name ="file://"+package_name
    if name.find(packageversion) != -1: name = name.replace(packageversion, '${PV}')
    if name.find(bpn) != -1: name = name.replace(bpn,'${BPN}')
    if name.find('${BPN}-${PV}') != -1: name = name.replace('${BPN}-${PV}','${BP}')
    return name

    
def encrypt(fpath: str, algorithm: str) -> str:
    with open(secure_filename(fpath), 'rb') as f:
        hash = hashlib.new(algorithm)
        for chunk in iter(lambda: f.read(2**20), b''):
            hash.update(chunk)
        return hash.hexdigest()


def delete_None_rows(filename):
    with open(secure_filename(filename),'r') as r:
        lines=r.readlines()
    with open(filename,'w') as w:
        for l in lines:
            if 'None' not in l:
                w.write(l)


def clearBlankLine(filename):
    with open(secure_filename(filename),'r') as r:
        lines=r.readlines()
        filecount = len(lines)
    with open(secure_filename(filename),'w') as w:
        for count, l in enumerate(lines):
            if count+1 == filecount:
                break
            if l != '\n':
                w.write(l)
            if l == '\n' and lines[count+1] != '\n':
                w.write(l)
 

def inspect_existing_files(file_name):
    temp_file_name = file_name
    i = 1
    while i:
        if os.path.exists(temp_file_name):
            name = file_name
            name += '.' + str(i) 
            temp_file_name_copy = name
            i = i+1
            print("\033[33m[Warning] : File %s already exists, make a copy %s.\033[0m" %(temp_file_name,temp_file_name_copy))
            temp_file_name = temp_file_name_copy
        else:
            return temp_file_name


def path_exists(path):
    if os.path.exists(path):
        path = os.path.abspath(path)
    else:
        print("\033[31m[ERROR] : Please correctly enter the relative or absolute path.\033[0m")
        sys.exit()
    return path


def decompression_path(package_dir):
    tar = tarfile.open(package_dir)
    name = tar.getnames()[0]
    if name.find(packageversion) != -1: name = name.replace(packageversion, '${PV}')
    if name.find(bpn) != -1: name = name.replace(bpn,'${BPN}')
    if name.find('${BPN}-${PV}') != -1: name = name.replace('${BPN}-${PV}','${BP}')
    return name

#From:/yocto-poky/meta/lib/oe/utils.py
def prune_suffix(var, suffixes):
    # See if var ends with any of the suffixes listed and
    # remove it if found
    for suffix in suffixes:
        if suffix and var.endswith(suffix):
            var = var[:-len(suffix)]
    return var

#From:/yocto-poky/bitbake/lib/bb/parse/__init__.py
class ParseError(Exception):
    """Exception raised when parsing fails"""
    def __init__(self, msg, filename, lineno=0):
        self.msg = msg
        self.filename = filename
        self.lineno = lineno
        Exception.__init__(self, msg, filename, lineno)

    def __str__(self):
        if self.lineno:
            return "ParseError at %s:%d: %s" % (self.filename, self.lineno, self.msg)
        else:
            return "ParseError in %s: %s" % (self.filename, self.msg)
# Used by OpenEmbedded metadata
__pkgsplit_cache__={}
def vars_from_file(mypkg, d):
    if not mypkg or not mypkg.endswith((".bb", ".bbappend")):
        return (None, None, None)
    if mypkg in __pkgsplit_cache__:
        return __pkgsplit_cache__[mypkg]

    myfile = os.path.splitext(os.path.basename(mypkg))
    parts = myfile[0].split('_')
    __pkgsplit_cache__[mypkg] = parts
    if len(parts) > 3:
        raise ParseError("Unable to generate default variables from filename (too many underscores)", mypkg)
    exp = 3 - len(parts)
    tmplist = []
    while exp != 0:
        exp -= 1
        tmplist.append(None)
    parts.extend(tmplist)
    return parts


class BuildData:
 
    def Init(self):
        mycode = []
        
        # get parameters
        spec_dir = search_specfile(args.spec)
        package_dir = search_package(spec_dir)
        bb_dir = search_bb_file(read_name(spec_dir))
        bbappend:path = generate_bbappend:path(bb_dir)
        pn = vars_from_file(bb_dir,bb_dir)[0]
        global pv
        pv = read_oldPV(vars_from_file(bb_dir,bb_dir)[1],bb_dir)
        global packageversion
        packageversion = read_packageversion(spec_dir,package_dir)
        global bpn
        SPECIAL_PKGSUFFIX = ["-native","-cross","-initial","-intermediate","-crosssdk","-cross-canadian"]
        bpn = prune_suffix(pn,SPECIAL_PKGSUFFIX)
        

        # import template
        template_file = open(os.path.abspath(os.path.join(current_path,'./bbappend.tmpl')), 'r')
        tmpl = Template(template_file.read())     
            
        # replace template
        print('Generating......')
        mycode.append(tmpl.substitute(
            BB_DIR = notes_bb_dir(bb_dir),
            NAME = read_repo_name(spec_dir),
            VERSION = update_PV(packageversion,pv),
            ORIG_SRC = read_original_source(bb_dir),
            PATCH = read_patch(spec_dir),
            PACKAGE = read_local_source(package_dir),
            MD5 = encrypt(package_dir, 'md5'),
            SHA256 = encrypt(package_dir, 'sha256'),
            WORKDIR = '${WORKDIR}',
            DECOMPRESSION = decompression_path(package_dir),
            PV = '${PV}',
            BP = '${BP}',
            BPN = '${BPN}',
            ))
        template_file.close()
        # Write code to file
        if not os.path.exists(bbappend:path):os.makedirs(bbappend:path)
        filePath = bbappend:path+'/'+bpn+'_%.bbappend'
        filePath = inspect_existing_files(filePath)
        class_file = open(secure_filename(filePath), 'w')
        class_file.writelines(mycode)
        class_file.close()
        delete_None_rows(filePath)
        clearBlankLine(filePath)
 
        print('\033[32mGenerated successfully!\033[0m')
 
if __name__ == '__main__':
    
    args = parse_args()	
    build = BuildData()
    build.Init()
