STAGES_RES = []
OEBUILD_DIR = "/home/jenkins/oebuild_workspace"
AGENT = "/home/jenkins/agent"
LOG_DIR = "openeuler/logs"
YOCTO_NAME = "yocto-meta-openeuler"

def downloadEmbeddedCI(String remote_url, String branch){
    sh 'rm -rf embedded-ci'
    sh "git clone ${remote_url} -b ${branch} -v embedded-ci --depth=1"
}

def downloadYoctoWithBranch(String workspace, String repo_remote, String branch, Integer deepth){
    dir(workspace){
        sh 'rm -rf yocto-meta-openeuler'
        sh "git clone ${repo_remote} -b ${branch} --depth=${deepth}"
    }
}

def downloadYoctoWithPr(String workspace, String repo_remote, Integer prnum, Integer deepth){
    dir(workspace){
        sh 'rm -rf yocto-meta-openeuler'
    }
    sh """
        python3 main.py clone_repo \
        -w ${workspace} \
        -r ${repo_remote} \
        -p ${YOCTO_NAME} \
        -pr ${prnum} \
        -dp ${deepth}
    """
}

def split_build(String build_images, String parallel_str_num){
    def build_list = [:]
    def parallel_num = parallel_str_num.toInteger()
    def image_list = build_images.replace("\n", " ").split(" ")
    def build_index = 0
    for(int i = 0; i < image_list.size(); i++){
        if (build_index >= parallel_num){
            build_index = 0
        }
        if (build_list[build_index] == null) {
            build_list[build_index] = image_list[i]
        }else{
            build_list[build_index] = build_list[build_index] + " " + image_list[i]
        }
        build_index = build_index + 1
    }
    return build_list
}

def formatRes(String name, String action, String check_res, String log_path){
    return sh (script: """
        python3 main.py serial \
            -c name=${name} \
            -c action=${action} \
            -c result=${check_res} \
            -c log_path=${log_path}
    """, returnStdout: true).trim()
}

def deleteBuildDir(String build_dir){
    sh """
        rm -rf ${build_dir}
    """
}

def getRandomStr(){
    return sh(script: """
        cat /proc/sys/kernel/random/uuid
    """, returnStdout: true).trim()
}

def mkdirOpeneulerLog(){
    dir(AGENT){
        sh "mkdir -p ${LOG_DIR}"
    }
}

def artifactsLogs(){
    dir(AGENT){
        sh "ls -al ${LOG_DIR}"
        archiveArtifacts artifacts: "${LOG_DIR}/*.log", fingerprint: true
    }
}

def getNowDatetime(){
    return sh(script: """
        date "+%Y%m%d%H%M%S"
    """, returnStdout: true).trim()
}

def uploadTarImageWithKey(String remote_ip, String remote_dir, String username, String remote_key, String local_dir){
    sh """
        timestamp=`basename ${local_dir}`
        dir_name=`dirname ${local_dir}`
        cd \${dir_name}
        tar zcf \${timestamp}.tar.gz \${timestamp}
        ssh -i ${remote_key} -o 'StrictHostKeyChecking no' ${username}@${remote_ip} "mkdir -p ${remote_dir}"
        scp -i ${remote_key} -o 'StrictHostKeyChecking no' \${timestamp}.tar.gz ${username}@${remote_ip}:${remote_dir}
    """
}

def uploadImageWithKey(String remote_ip, String remote_dir, String username, String remote_key, String local_dir){
    sh """
        python3 main.py put_to_dst \
        -t 0 \
        -ld $local_dir \
        -dd $remote_dir \
        -i $remote_ip \
        -u $username \
        -k $remote_key \
        -sign \
        -d
    """
}

def putSStateCacheToDst(String local_dir, String dst_dir){
    sh """
        python3 main.py put_to_dst \
        -t 1 \
        -dd ${dst_dir} \
        -ld ${local_dir}
    """
}

def uploadLogWithKey(String remote_ip, String remote_dir, String username, String remote_key, String local_path){
    sh """
        scp -i ${remote_key} -o 'StrictHostKeyChecking no' ${local_path} ${username}@${remote_ip}:${remote_dir}
    """
}

def handleLog(String log_file){
    log_path = "${LOG_DIR}/${log_file}"
    if (env.isUploadLog != null && env.isUploadLog == "true"){
        withCredentials([
            file(credentialsId: openEulerLogRemoteKey, variable: 'openEulerLogKey')
        ]){
            def local_log_path = "${AGENT}/${log_path}"
            uploadLogWithKey(openEulerLogRemoteIP,
                            openEulerLogRemoteDir,
                            openEulerLogRemoteUser,
                            openEulerLogKey,
                            local_log_path)
        }
        log_path = "${openEulerLogRemoteUrl}/${log_file}"
    }else{
        log_path = "artifact/${log_path}"
    }
    return log_path
}

def handleAfterBuildImage(String image_name,
                        String arch,
                        Integer build_res_code,
                        String random_str,
                        String image_date){
    def build_res = "failed"
    def test_res = "failed"
    def test_res_code = 1
    if (build_res_code == 0){
        build_res = "success"
        if (env.isUploadImg != null && env.isUploadImg == "true"){
            // put the image to remote server
            def remote_dir = openEulerImgRemoteDir+"/${arch}/${image_name}"
            def local_dir = "${OEBUILD_DIR}/build/${image_name}/output/${image_date}/"
            withCredentials([
                file(credentialsId: env.openEulerImgRemoteKey, variable: 'openEulerImgKey')
            ]){
                uploadTarImageWithKey(openEulerImgRemoteIP,
                                remote_dir,
                                openEulerImgRemoteUser,
                                openEulerImgKey,
                                local_dir)
            }
        }
        if (env.isSaveCache != null && env.isSaveCache == "true"){
            // put sstate-cache to share disk
            // Due to the current sstate-cache containing soft links pointing to files in
            // sstate_origin_dir, we first copy it to a temporary folder (during copying,
            // soft links are defaulted to copy the actual files they point to), then delete
            // the source folder, and finally perform an mv operation.
            def sstate_local_dir = "${OEBUILD_DIR}/build/${image_name}/sstate-cache"
            def sstate_dst_dir = "${shareDir}/${ciBranch}/sstate-cache/${image_name}-temp"
            putSStateCacheToDst(sstate_local_dir, sstate_dst_dir)
            def sstate_origin_dir = "${shareDir}/${ciBranch}/sstate-cache/${image_name}"
            sh """
                rm -rf ${sstate_origin_dir}
                mv ${sstate_dst_dir} ${sstate_origin_dir}
            """
        }
        if (env.isTest != null && env.isTest == "true"){
            // Test the build artifacts of the QEMU image and x86 image.
            if(image_name.contains("qemu") && image_name.contains("x86-64") && !image_name.contains("riscv")){
                test_res_code = sh (script: """
                    python3 main.py utest \
                    -target openeuler_image \
                    -a ${arch} \
                    -td ${OEBUILD_DIR}/build/${image_name} \
                    -tm ${mugenRemote} \
                    -tb ${mugenBranch} > ${AGENT}/${LOG_DIR}/Test-${image_name}-${random_str}.log
                """, returnStatus: true)
                if (test_res_code == 0){
                    test_res = "success"
                }
                log_file = "Test-${image_name}-${random_str}.log"
                log_path = handleLog(log_file)
                STAGES_RES.push(formatRes(image_name, "test", test_res, log_path))
            }
        }
    }

    // if need to upload log to remote
    log_file = "Build-${image_name}-${random_str}.log"
    log_path = handleLog(log_file)
    STAGES_RES.push(formatRes(image_name, "build", build_res, log_path))
}

def translateCompileToHost(String yocto_dir,
                        String arch,
                        String image_name,
                        String image_date,
                        String cache_src_dir){
    def read_image_yaml = "${yocto_dir}/.oebuild/samples/${arch}/${image_name}.yaml"
    def samples_dir = "/home/jenkins/agent/samples/${arch}"
    sh "mkdir -p ${samples_dir}"
    def write_image_yaml = "${samples_dir}/${image_name}.yaml"
    def code = """
import subprocess
try:
    from ruamel.yaml import YAML
except ModuleNotFoundError:
    subprocess.call(args="pip install ruamel.yaml -i https://pypi.tuna.tsinghua.edu.cn/simple",
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    shell=True)
    from ruamel.yaml import YAML

with open("$read_image_yaml", "r", encoding="utf-8") as file:
    yaml = YAML()
    data = yaml.load(file.read())

data["build_in"] = "host"
data["cache_src_dir"] = "$cache_src_dir"
data["local_conf"] += '\\nDATETIME = "$image_date"\\nINHERIT += "rm_work"'

with open("$write_image_yaml", "w", encoding="utf-8") as file:
    yaml = YAML()
    yaml.dump(data, file)
"""
    def file_name = getRandomStr()
    writeFile file: file_name, text: code, encoding: "UTF-8"
    sh "python3 ${file_name}"
    return write_image_yaml
}

// dynamic invoke build image function
def dynamicBuild(String yocto_dir,
                String arch,
                String image_name,
                String image_date,
                String random_str,
                String cache_src_dir){
    compile_path = translateCompileToHost(yocto_dir, arch, image_name, image_date, cache_src_dir)
    // prepare oebuild build environment
    def task_res_code = sh (script: """
        oebuild init ${OEBUILD_DIR}
        cd ${OEBUILD_DIR}
        mkdir -p build
        ln -sf ${yocto_dir} src/yocto-meta-openeuler
        oebuild ${compile_path} > ${AGENT}/${LOG_DIR}/Build-${image_name}-${random_str}.log
    """, returnStatus: true)
    handleAfterBuildImage(image_name, arch, task_res_code, random_str, image_date)
    // delete build directory
    deleteBuildDir(OEBUILD_DIR + "/build/" + image_name)
}

def stashRepo(String workdir,String stash_name){
    dir(workdir+"/"+stash_name){
        sh """
        if [ -d .git ];then
            mv .git .git_bak
        fi
        """
        stash(stash_name)
        // the stash will not include .git, so mv .git to .git_bak
        sh """
        if [ -d .git_bak ];then
            mv .git_bak .git
        fi
        """
    }
}

def unstashRepo(String workdir,String stash_name){
    dir(workdir){
        sh "rm -rf $stash_name"
        sh "mkdir -p $stash_name"
    }
    dir(workdir+"/"+stash_name){
        unstash(name: stash_name)
        sh """
        if [ -d .git_bak ] && [ ! -d .git ];then
            mv .git_bak .git
        fi
        """
    }
}

def buildTask(String build_imgs, String image_date){
    unstashRepo('/home/jenkins/agent', 'embedded-ci')
    unstashRepo('/home/jenkins/agent', 'yocto-meta-openeuler')
    dir('/home/jenkins/agent/embedded-ci'){
        def randomStr = getRandomStr()
        mkdirOpeneulerLog()
        cacheSrcDir = "$shareDir/$ciBranch/oebuild_workspace/src"
        for (imageName in build_imgs.split()){
            println "build ${imageName} ..."
            imageSplit = imageName.split("/")
            yoctoDir = "/home/jenkins/agent/yocto-meta-openeuler"
            dynamicBuild(yoctoDir,
                        imageSplit[0],
                        imageSplit[1],
                        image_date,
                        randomStr,
                        cacheSrcDir)
        }
        artifactsLogs()
    }
}

def get_remote_images(String base_url) {
    def code = """
import requests
import subprocess
try:
    from bs4 import BeautifulSoup
except ModuleNotFoundError:
    subprocess.call(args="pip install bs4 -i https://pypi.tuna.tsinghua.edu.cn/simple",
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    shell=True)
    subprocess.call(args="pip install lxml -i https://pypi.tuna.tsinghua.edu.cn/simple",
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    shell=True)
    from bs4 import BeautifulSoup
import re

def get_pre_text(url, typ):
    res = []
    content = requests.get(url)
    resHTML = content.text
    soup = BeautifulSoup(resHTML, 'lxml')
    for item in soup.pre.children:
        for dir_name in item.text.split(" "):
            if typ == "dir" and dir_name.endswith("/") and not dir_name.startswith("."):
                res.append(dir_name)
                continue
            if typ == "gz" and dir_name.endswith(".tar.gz") and not dir_name.startswith("."):
                res.append(dir_name)
    return res

# get image list
base_url = "$base_url"
image_list = get_pre_text(base_url, "dir")
target_list = []
for image in image_list:
    time_list = get_pre_text(base_url + "/" + image, "gz")
    tmp_times = []
    for time_name in time_list:
        match = re.search("^[0-9]{14}(.tar.gz)\$", time_name)
        if match:
            tmp_times.append(time_name.replace(".tar.gz", ""))
    tmp_times.sort(reverse=True)
    if len(tmp_times) > 0:
        target_list.append(image + tmp_times[0])

print(" ".join(target_list))
"""

file_name = getRandomStr()
writeFile file: file_name, text: code, encoding: "UTF-8"
return sh (script: """
    python3 ${file_name}
""", returnStdout: true).trim()
}

def remote_address_exists(String base_url){
    def code = """
import requests

content = requests.get("$base_url")
if content.status_code == 200:
    print("yes")
else:
    print("no")
"""

file_name = getRandomStr()
writeFile file: file_name, text: code, encoding: "UTF-8"
return sh (script: """
    python3 ${file_name}
""", returnStdout: true).trim()
}

return this
